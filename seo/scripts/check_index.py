#!/usr/bin/env python3
"""检查指定 URL 是否满足 Google 索引基础条件。

用法:
    python3 check_index.py https://sub.example.com/page

覆盖技能树中可自动化的 P0/P1 检查项，失败项给出对应 skill 路由。
GSC 相关步骤（测试实际网址/请求索引/监控报告）需手动完成。
"""

import argparse
import re
import sys
import urllib.error
import urllib.parse
import urllib.request

DESKTOP_UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"
MOBILE_UA = "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.96 Mobile Safari/537.36"

results = []  # (ok: bool|None, name, detail, skill)


def report(ok, name, detail, skill=None):
    results.append((ok, name, detail, skill))
    icon = {True: "✅", False: "❌", None: "ℹ️ "}[ok]
    line = f"{icon} {name}: {detail}"
    if skill and ok is False:
        line += f"  → 修复参考 skill: {skill}"
    print(line)


def fetch(url, ua=DESKTOP_UA, method="GET", timeout=15):
    """返回 (status, headers, body_str, final_url, redirect_chain)"""
    chain = []

    class NoRedirect(urllib.request.HTTPRedirectHandler):
        def redirect_request(self, req, fp, code, msg, headers, newurl):
            return None

    current = url
    for _ in range(10):
        req = urllib.request.Request(current, method=method, headers={"User-Agent": ua})
        opener = urllib.request.build_opener(NoRedirect)
        try:
            resp = opener.open(req, timeout=timeout)
            status, headers = resp.status, resp.headers
            body = resp.read() if method == "GET" else b""
            return status, headers, body.decode("utf-8", errors="replace"), current, chain
        except urllib.error.HTTPError as e:
            if e.code in (301, 302, 303, 307, 308):
                location = e.headers.get("Location", "")
                chain.append((current, e.code, location))
                current = urllib.parse.urljoin(current, location)
                continue
            return e.code, e.headers, "", current, chain
        except Exception as e:
            return None, {}, str(e), current, chain
    return None, {}, "重定向次数过多", current, chain


def check_http_status(url):
    status, _, body, final, chain = fetch(url)
    if status == 200 and not chain:
        report(True, "HTTP 状态码", f"200 OK，无跳转")
    elif status == 200 and chain:
        codes = " → ".join(f"{c[1]}" for c in chain) + " → 200"
        if len(chain) > 1:
            report(False, "HTTP 状态码", f"链式跳转 {codes}，应压平为一步 301", "google-http-status")
        else:
            code = chain[0][1]
            if code == 301:
                report(True, "HTTP 状态码", f"301 → {final}")
            else:
                report(False, "HTTP 状态码", f"使用 {code}（临时跳转）做迁移，权重传递不稳定", "google-http-status")
    else:
        report(False, "HTTP 状态码", f"返回 {status}（{body[:60]}）" if status else f"请求失败: {body[:80]}", "google-http-status")
    return status, final


def check_robots_txt(url):
    p = urllib.parse.urlparse(url)
    robots_url = f"{p.scheme}://{p.netloc}/robots.txt"
    status, _, body, _, _ = fetch(robots_url)
    if status != 200:
        report(None, "robots.txt", f"{robots_url} 返回 {status}（视为无限制）")
        return
    if re.search(r"Disallow:\s*/\s*$", body, re.M):
        report(False, "robots.txt", "存在整站 Disallow: /，全站屏蔽", "google-crawlability")
    else:
        path = p.path or "/"
        blocked = False
        for m in re.finditer(r"Disallow:\s*(\S+)", body):
            rule = m.group(1)
            if rule and path.startswith(rule):
                report(False, "robots.txt", f"路径被规则屏蔽: Disallow: {rule}", "google-crawlability")
                blocked = True
                break
        if not blocked:
            report(True, "robots.txt", "未屏蔽目标路径")


def check_index_directives(url):
    status, headers, body, _, _ = fetch(url)
    if status != 200:
        report(None, "索引指令", "页面非 200，跳过")
        return
    xrt = headers.get("X-Robots-Tag", "")
    meta = re.search(r'<meta[^>]+name=["\']robots["\'][^>]*content=["\']([^"\']+)', body, re.I)
    meta_val = meta.group(1) if meta else ""
    problems = []
    if re.search(r"noindex|none", xrt, re.I):
        problems.append(f"响应头 X-Robots-Tag: {xrt}")
    if re.search(r"noindex|none", meta_val, re.I):
        problems.append(f"meta robots: {meta_val}")
    if problems:
        report(False, "索引指令", "; ".join(problems), "google-index-directives")
    else:
        report(True, "索引指令", "无 noindex（meta robots 与 X-Robots-Tag）")


def check_canonical(url):
    status, _, body, _, _ = fetch(url)
    if status != 200:
        report(None, "Canonical", "页面非 200，跳过")
        return
    m = re.search(r'<link[^>]+rel=["\']canonical["\'][^>]*href=["\']([^"\']+)', body, re.I)
    if not m:
        m2 = re.search(r'<link[^>]+href=["\']([^"\']+)["\'][^>]*rel=["\']canonical["\']', body, re.I)
        m = m2
    if not m:
        report(False, "Canonical", "页面缺少 canonical 标签", "google-canonical")
        return
    canon = m.group(1).rstrip("/")
    current = url.rstrip("/")
    if canon == current:
        report(True, "Canonical", f"自引用: {m.group(1)}")
    else:
        report(False, "Canonical", f"指向 {m.group(1)} ≠ 当前 URL，可能被忽略", "google-canonical")


def check_sitemap(url):
    p = urllib.parse.urlparse(url)
    base = f"{p.scheme}://{p.netloc}"
    candidates = [f"{base}/sitemap.xml", f"{base}/sitemap_index.xml"]
    found = None
    status, _, body, _, _ = fetch(f"{base}/robots.txt")
    if status == 200:
        m = re.search(r"Sitemap:\s*(\S+)", body, re.I)
        if m:
            candidates.insert(0, m.group(1))
    for sm in candidates:
        s, _, b, _, _ = fetch(sm)
        if s == 200 and ("<urlset" in b or "<sitemapindex" in b):
            found = sm
            in_sitemap = url in b
            break
    if found:
        detail = f"{found}"
        detail += "，包含目标 URL" if in_sitemap else "（目标 URL 未在其中，若为索引型 sitemap 属正常）"
        report(True, "Sitemap", detail)
    else:
        report(False, "Sitemap", f"{base} 下未找到可用 sitemap，需在 GSC 提交", "google-sitemap")


def check_mobile_parity(url):
    s1, _, b1, _, _ = fetch(url, ua=DESKTOP_UA)
    s2, _, b2, _, _ = fetch(url, ua=MOBILE_UA)
    if s1 != 200 or s2 != 200:
        report(None, "移动优先", f"桌面 {s1} / 移动 {s2}，跳过对比")
        return
    def text_len(html):
        return len(re.sub(r"<[^>]+>|\s", "", html))
    t1, t2 = text_len(b1), text_len(b2)
    m_noindex = bool(re.search(r'<meta[^>]+name=["\']robots["\'][^>]*content=["\'][^"\']*noindex', b2, re.I))
    if m_noindex:
        report(False, "移动优先", "移动版存在 noindex", "google-mobile-first")
    elif t1 > 0 and t2 / t1 < 0.6:
        report(False, "移动优先", f"移动版正文显著少于桌面版（{t2} vs {t1} 字符），移动优先索引下内容缺失", "google-mobile-first")
    else:
        report(True, "移动优先", f"移动/桌面内容量接近（{t2}/{t1} 字符）")


def check_internal_links(url, html=None):
    status, _, body, _, _ = fetch(url)
    if status != 200:
        report(None, "内链形态", "页面非 200，跳过")
        return
    total = len(re.findall(r"<a\s[^>]*href=", body, re.I))
    onclick = len(re.findall(r"onclick=[\"'][^\"']*location", body, re.I))
    if total == 0:
        report(False, "内链形态", "页面源码中无 <a href> 链接（可能纯 CSR 渲染）", "google-internal-links")
    elif onclick > total:
        report(False, "内链形态", f"JS 跳转({onclick}) 多于标准链接({total})，爬虫无法跟随", "google-internal-links")
    else:
        report(True, "内链形态", f"源码含 {total} 个 <a href> 链接")


def main():
    ap = argparse.ArgumentParser(description="Google 索引基础条件检查")
    ap.add_argument("url", help="要检查的页面完整 URL")
    args = ap.parse_args()
    url = args.url if args.url.startswith("http") else "https://" + args.url

    print(f"\n检查目标: {url}\n{'=' * 50}")
    print("\n-- P0 基础放行 --")
    check_http_status(url)
    check_robots_txt(url)
    check_index_directives(url)
    print("\n-- P1 发现与规范 --")
    check_sitemap(url)
    check_canonical(url)
    check_mobile_parity(url)
    check_internal_links(url)

    failed = [r for r in results if r[0] is False]
    print(f"\n{'=' * 50}")
    print(f"结果: {len(results) - len(failed)} 项通过 / {len(failed)} 项失败")
    if failed:
        print("待修复:")
        for _, name, _, skill in failed:
            print(f"  - {name} → skill: {skill}")
    print("\n-- 需手动完成（GSC）--")
    print("  1. GSC「测试实际网址」实时抓取验证 → google-crawlability")
    print("  2. GSC 提交 sitemap → google-sitemap")
    print("  3. GSC「请求编入索引」（每日配额 10-15）→ google-request-indexing")
    print("  4. 持续监控页面索引报告 → google-gsc-monitoring")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Remove commit/changelog comments and sanitize hostnames, server names, and IP addresses."""
from __future__ import annotations

import hashlib
import re
import sys
from pathlib import Path

WORKSPACE = Path(__file__).resolve().parent.parent

SKIP_DIRS = {".git", "node_modules", "bin", "obj", "packages"}
SKIP_FILES = {"package-lock.json", "cleanup-commit-comments-and-sanitize.py", "sanitize-org-references.py"}
TEXT_EXTENSIONS = {
    ".ps1", ".psm1", ".psd1", ".ps1xml", ".vbs", ".hta", ".txt", ".csv", ".bat",
    ".cmd", ".xml", ".html", ".htm", ".json", ".md", ".yml", ".yaml", ".config",
    ".sql", ".ini", ".log", ".ps1", ".PS1",
}

PRESERVE_IPS = {
    "0.0.0.0", "127.0.0.1", "255.255.255.255", "::1", "::",
}

# Lines to strip (commit / changelog metadata)
COMMIT_LINE_PATTERNS = [
    re.compile(r"^\s*\.?(?:NOTES|Notes)\s*$", re.I),
    re.compile(r"^\s*(?:#+\s*)?(?:Author|AUTHORS?|Created|DateCreated|Last\s+Edit|Last\s+Modified|Modified|Updated|Updated\s+by|Created\s+by)\s*:", re.I),
    re.compile(r"^\s*::\s*(?:AUTHOR|VERSION)\s*:", re.I),
    re.compile(r"^\s*\.?(?:AUTHOR|DATE|VERSION)\s", re.I),
    re.compile(r"^\s*Changes?\s*:\s*$", re.I),
    re.compile(r"^\s*History\s+Version\s*$", re.I),
    re.compile(r"^\s*#\s*(?:Author|AUTHORS?|Created|Last\s+Edit|History\s+Version|Name\s*:|Website|Twitter)\s", re.I),
    re.compile(r"^\s*#\s*\d+\.\d+\s+\d{8}\s", re.I),
    re.compile(r"^\s*\d{1,2}/\d{1,2}/\d{4}\s*-", re.I),
    re.compile(r"^\s*\d{4}-\d{2}-\d{2}\s*-", re.I),
    re.compile(r"^\s*Version\s+\d+(?:\.\d+)*\s*-\s*\d{1,2}/\d{1,2}/\d{4}", re.I),
    re.compile(r"^\s*::\s*VERSION\s*:", re.I),
    re.compile(r"^\s*Copyright\s+\(c\)\s+\d{4}\s+by\s+", re.I),
    re.compile(r"^\s*Free\s+for\s+personal\s+or\s+commercial\s+use", re.I),
    re.compile(r"^\s*No\s+warranties\.\s*Use\s+at\s+your\s+own\s+risk", re.I),
    re.compile(r"^\s*Name:\s+\S+\.(?:ps1|psm1)", re.I),
    re.compile(r"^\s*Organization:\s*", re.I),
    re.compile(r"^\s*#\s*=+\s*$"),
    re.compile(r"^\s*#\s*Name\s+\t:", re.I),
    re.compile(r"^\s*DateCreated:\s*", re.I),
    re.compile(r"^\s*DateModified:\s*", re.I),
    re.compile(r"^\s*LastEdit:\s*", re.I),
]

CHANGELOG_CONTINUATION = re.compile(
    r"^\s{4,}(?:Add |Rename |Change |Edit |When |Also |Note that|For Windows|Output may|"
    r"suppress|Add a column|Retrieve and|Otherwise indicated|This lets|Reformat|"
    r"Identify the|List |Remove |Include |Show |Use Format|Getting true|Edit note|"
    r"Change default|If the machine|WUServer|WUStatusServer|Copy to a text|"
    r"so total size|editor without|- For Windows|which controls when|No longer used|"
    r"Most of the|bundled updates|Adapted from|Also see https?://)",
    re.I,
)

IPV4_RE = re.compile(
    r"(?<![\w.])(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})(?![\w.])"
)

# Skip version strings in assembly references
ASSEMBLY_CONTEXT = re.compile(r"Version\s*=\s*\d+\.\d+\.\d+\.\d+", re.I)

HOSTNAME_PATTERNS = [
    re.compile(r"\bSAT-\d{3,4}\b", re.I),
    re.compile(r"\bSERVER-\d{3,4}\b", re.I),
    re.compile(r"\bPHX[-A-Z0-9]+\b", re.I),
    re.compile(r"\bphx[a-z0-9-]+\b", re.I),
    re.compile(r"\b[A-Z]{2,5}-(?:VAPP|VFAX|VSQL|FSS)-\d+\b", re.I),
    re.compile(r"\b[A-Z]{2,5}\d{4,5}\b"),
    re.compile(r"\b(?:hamburg|dc01)\b", re.I),
    re.compile(r"\b\d{1,3}(?:\.\d{1,3}){3}\.(?:local|corp|internal|lan|ad|int)\b", re.I),
    re.compile(
        r"\b[A-Za-z0-9][-A-Za-z0-9]*\.(?:local|corp|internal|lan|ad|int)\b",
        re.I,
    ),
    re.compile(r"\\\\([A-Za-z0-9_-]+)\\", re.I),
    re.compile(r"-ComputerName\s+['\"]?([A-Za-z0-9_.-]+)['\"]?", re.I),
    re.compile(r"\$Server(?:s)?\s*=\s*['\"]([A-Za-z0-9_.-]+)['\"]", re.I),
    re.compile(r"-computer\s+([A-Za-z0-9_.-]+)", re.I),
    re.compile(r"-computername\s+([0-9]{1,3}(?:\.[0-9]{1,3}){3}|[A-Za-z0-9_.-]+)", re.I),
]

FOLDER_DESCRIPTIONS = {
    "Active-Directory": "Active Directory user, group, and domain administration",
    "Azure": "Microsoft Azure cloud resource management",
    "BitLocker": "BitLocker drive encryption management",
    "Certificates": "PKI and certificate lifecycle operations",
    "Computer-Info": "Computer hardware and system inventory",
    "Computer-Maintenance": "Routine computer maintenance and cleanup",
    "Disk-Space": "Disk space monitoring and reporting",
    "Event-Logs": "Windows event log querying and analysis",
    "Exchange-Online": "Exchange Online mailbox and mail flow administration",
    "File-Management": "File and folder management utilities",
    "Firewall": "Windows Firewall configuration and auditing",
    "General": "General-purpose PowerShell utilities",
    "Group-Policy": "Group Policy Object management",
    "HP-Radia-HPCA": "HP Radia client automation and satellite servers",
    "HTML-Reports": "HTML report generation utilities",
    "Infrastructure": "Core infrastructure automation scripts",
    "Intune": "Microsoft Intune endpoint management",
    "Inventory": "Hardware and software inventory collection",
    "LANDesk": "Ivanti LANDesk endpoint management",
    "McAfee-ePO": "McAfee ePolicy Orchestrator reporting",
    "Microsoft-365": "Microsoft 365 tenant administration",
    "Monitoring": "System monitoring and alerting",
    "Networking": "Network diagnostics, DNS, DHCP, and connectivity",
    "OS-Deployment": "Operating system deployment automation",
    "PSRemoting": "PowerShell remoting and WinRM configuration",
    "Registry": "Windows registry read and write operations",
    "Reporting": "IT reporting and dashboard generation",
    "SCCM-ConfigMgr": "Configuration Manager collections and deployments",
    "SCOM": "System Center Operations Manager monitoring",
    "SQL-Server": "SQL Server administration and queries",
    "Security": "Security auditing and compliance checks",
    "SharePoint-Online": "SharePoint Online site administration",
    "Storage": "Storage management and disk operations",
    "Teams": "Microsoft Teams lifecycle management",
    "Threat-Intelligence": "Threat intelligence and vulnerability data",
    "Windows-Desktop": "Windows desktop configuration and management",
    "Windows-Updates": "Windows Update and patch management",
    "WSUS": "Windows Server Update Services administration",
    "Modules": "Reusable PowerShell function libraries",
    "Shared": "Cross-cutting logging, error handling, and utilities",
    "Tools": "Standalone GUI applications and utilities",
    "Snippets": "PowerShell profile and ISE snippets",
    "Reference": "Certification notes and learning materials",
    "docs": "Repository documentation and assets",
    "scripts": "Repository maintenance and migration scripts",
}


def should_process(path: Path) -> bool:
    if path.name in SKIP_FILES:
        return False
    if not path.suffix or path.suffix.lower() in TEXT_EXTENSIONS:
        pass
    elif path.suffix not in TEXT_EXTENSIONS:
        return False
    if set(path.parts) & SKIP_DIRS:
        return False
    if path.name == "MyOrganizationSdkTypes.cs" and path.stat().st_size > 1_000_000:
        return False
    return True


def stable_random_ip(key: str) -> str:
    digest = hashlib.md5(key.encode()).hexdigest()
    a, b, c, d = (int(digest[i : i + 2], 16) for i in range(0, 8, 2))
    # Avoid reserved / preserved-looking values
    if a == 127:
        a = 10
    if a == 0:
        a = 10
    if a == 255 and b == 255:
        a = 192
    return f"{a}.{b}.{c % 254 + 1}.{d % 254 + 1}"


def is_valid_ipv4(ip: str) -> bool:
    parts = ip.split(".")
    if len(parts) != 4:
        return False
    try:
        return all(0 <= int(p) <= 255 for p in parts)
    except ValueError:
        return False


def should_preserve_ip(ip: str) -> bool:
    if ip in PRESERVE_IPS:
        return True
    if ip.startswith("127."):
        return True
    # Common documentation / example ranges already sanitized
    if ip.startswith("192.0.2.") or ip.startswith("198.51.100.") or ip.startswith("203.0.113."):
        return False
    return False


def replace_ips(content: str, ip_map: dict[str, str]) -> str:
    def replacer(match: re.Match) -> str:
        ip = match.group(1)
        if not is_valid_ipv4(ip):
            return ip
        if should_preserve_ip(ip):
            return ip
        start = match.start()
        context = content[max(0, start - 20) : start + 30]
        if "Version=" in context or "PublicKeyToken" in context:
            return ip
        if ip not in ip_map:
            ip_map[ip] = stable_random_ip(ip)
        return ip_map[ip]

    return IPV4_RE.sub(replacer, content)


def replace_hostnames(content: str, ip_map: dict[str, str]) -> str:
    def host_to_ip(host: str) -> str:
        key = host.lower()
        if key in ("localhost", "example", "yourdomain", "contoso"):
            if key not in ip_map:
                ip_map[key] = stable_random_ip(key)
            return ip_map[key]
        if re.fullmatch(r"\d{1,3}(?:\.\d{1,3}){3}", host):
            return host
        if key not in ip_map:
            ip_map[key] = stable_random_ip(key)
        return ip_map[key]

    for pattern in HOSTNAME_PATTERNS:
        def sub_fn(match: re.Match, _pattern=pattern) -> str:
            original = match.group(0)
            if match.lastindex and match.lastindex >= 1:
                host = match.group(1)
                if host.lower() in ("localhost", "c$", "windows", "system32", "adminpak", "wsus", "wsuscontent"):
                    return original
                if "." in host and re.search(r"\.(?:local|corp|internal|lan|ad|int)$", host, re.I):
                    return host_to_ip(host.split(".")[0])
                replacement = host_to_ip(host)
                return original.replace(host, replacement)
            host = match.group(0)
            return host_to_ip(host)

        content = pattern.sub(sub_fn, content)

    # Fix IP.domain.local artifacts from partial replacements
    content = re.sub(
        r"\b(\d{1,3}(?:\.\d{1,3}){3})\.(?:local|corp|internal|lan|ad|int)\b",
        r"\1",
        content,
        flags=re.I,
    )
    return content


def is_commit_metadata_line(line: str) -> bool:
    stripped = line.rstrip("\r\n")
    if not stripped.strip():
        return False
    for pattern in COMMIT_LINE_PATTERNS:
        if pattern.search(stripped):
            return True
    # Version history lines: tab/space separated version + date
    if re.match(r"^\s*#?\s*\d+\.\d+\s+\d{6,8}\s", stripped):
        return True
    if re.match(r"^\s*#\s+\d+\.\d+\s+\d{6,8}\s", stripped):
        return True
    return False


def remove_header_block(content: str) -> str:
    """Remove #==== Name/Author/History header blocks at file start."""
    lines = content.splitlines(keepends=True)
    if not lines:
        return content

    i = 0
    while i < len(lines) and lines[i].strip() == "":
        i += 1

    if i >= len(lines):
        return content

    first = lines[i]
    if not re.match(r"^\s*#\s*=+\s*$", first):
        return content

    # Consume until closing ==== line or non-comment
    j = i + 1
    while j < len(lines):
        if re.match(r"^\s*#\s*=+\s*$", lines[j]):
            j += 1
            break
        if not lines[j].lstrip().startswith("#") and lines[j].strip():
            break
        j += 1

    return "".join(lines[:i] + lines[j:])


def clean_comment_block(block: str) -> str:
    lines = block.splitlines(keepends=True)
    cleaned = []
    in_changes = False
    in_notes = False
    skip_changelog_prose = False

    for line in lines:
        stripped = line.strip()
        lower = stripped.lower()

        if re.match(r"^\.?(?:notes|notes)\s*$", stripped, re.I):
            in_notes = True
            skip_changelog_prose = True
            continue
        if in_notes and re.match(r"^\.(?:synopsis|description|parameter|example|link|inputs|outputs)", stripped, re.I):
            in_notes = False
            skip_changelog_prose = False

        if re.match(r"^changes?\s*:\s*$", stripped, re.I):
            in_changes = True
            skip_changelog_prose = True
            continue
        if in_changes:
            if not stripped or re.match(r"^\.(?:synopsis|description|parameter|example|link)", stripped, re.I):
                in_changes = False
                skip_changelog_prose = False
            else:
                continue

        if is_commit_metadata_line(line):
            skip_changelog_prose = True
            continue

        # Drop orphaned changelog prose lines inside help blocks (indented narrative updates)
        if skip_changelog_prose and in_notes:
            if re.match(r"^\.(?:synopsis|description|parameter|example|link)", stripped, re.I):
                skip_changelog_prose = False
            else:
                continue

        if skip_changelog_prose and in_changes:
            continue

        if CHANGELOG_CONTINUATION.match(line):
            continue

        cleaned.append(line)

    return "".join(cleaned)


def remove_commit_comments(content: str) -> str:
    content = remove_header_block(content)

    # Clean <# ... #> blocks
    def clean_multiline(match: re.Match) -> str:
        return clean_comment_block(match.group(0))

    content = re.sub(r"<#[\s\S]*?#>", clean_multiline, content)

    lines = content.splitlines(keepends=True)
    result = []
    for line in lines:
        if line.lstrip().startswith("#") or line.lstrip().startswith("<#"):
            if is_commit_metadata_line(line):
                continue
            if CHANGELOG_CONTINUATION.match(line):
                continue
        result.append(line)

    return "".join(result)


def infer_software_folder(path: Path) -> str | None:
    parts = path.parts
    for key in FOLDER_DESCRIPTIONS:
        if key in parts:
            return key
    return None


def verb_from_filename(name: str) -> str:
    stem = Path(name).stem
    stem = re.sub(r"[-_](RootCopy|v\d+(?:\.\d+)*)$", "", stem, flags=re.I)
    if "-" in stem:
        verb, noun = stem.split("-", 1)
        return f"{verb}-{noun.replace('-', ' ')}"
    if "_" in stem:
        return stem.replace("_", " ")
    return stem


def generate_purpose_comment(path: Path) -> str:
    rel = path.relative_to(WORKSPACE)
    folder = infer_software_folder(path)
    action = verb_from_filename(path.name)
    folder_desc = FOLDER_DESCRIPTIONS.get(folder or "", "PowerShell automation")

    if path.suffix.lower() in (".psm1",):
        return f"# Purpose: PowerShell module — {folder_desc}."
    if path.suffix.lower() in (".psd1",):
        return f"# Purpose: Module manifest for {folder_desc}."

    return f"# Purpose: {action} — {folder_desc}."


def has_purpose_or_synopsis(content: str) -> bool:
    head = content[:2000]
    return bool(
        re.search(r"(?im)^#\s*Purpose:", head)
        or re.search(r"(?im)^\.SYNOPSIS", head)
        or re.search(r"(?im)^<#\s*\n\s*\.SYNOPSIS", head)
    )


def add_purpose_comment(content: str, path: Path) -> str:
    if path.suffix.lower() not in (".ps1", ".psm1", ".psd1", ".PS1"):
        return content
    if has_purpose_or_synopsis(content):
        return content

    purpose = generate_purpose_comment(path) + "\n"
    # Skip shebang/requires
    lines = content.splitlines(keepends=True)
    insert_at = 0
    for i, line in enumerate(lines[:5]):
        if re.match(r"^\s*#Requires\b", line, re.I):
            insert_at = i + 1
    return purpose + "".join(lines[insert_at:])


def read_text(path: Path) -> tuple[str, str]:
    raw = path.read_bytes()
    if raw.startswith(b"\xff\xfe"):
        return raw.decode("utf-16-le"), "utf-16-le"
    if raw.startswith(b"\xfe\xff"):
        return raw.decode("utf-16-be"), "utf-16-be"
    if raw.startswith(b"\xef\xbb\xbf"):
        return raw.decode("utf-8-sig"), "utf-8-sig"
    return raw.decode("utf-8", errors="surrogateescape"), "utf-8"


def write_text(path: Path, content: str) -> None:
    path.write_text(
        content.encode("utf-8", errors="surrogateescape").decode("utf-8", errors="replace"),
        encoding="utf-8",
    )


def process_file(path: Path) -> bool:
    try:
        original, _ = read_text(path)
    except (OSError, UnicodeDecodeError):
        return False

    ip_map: dict[str, str] = {}
    updated = remove_commit_comments(original)
    updated = replace_ips(updated, ip_map)
    updated = replace_hostnames(updated, ip_map)
    updated = add_purpose_comment(updated, path)

    if updated != original:
        write_text(path, updated)
        return True
    return False


def main() -> int:
    changed: list[str] = []
    for path in sorted(WORKSPACE.rglob("*")):
        if path.is_file() and should_process(path):
            if process_file(path):
                changed.append(str(path.relative_to(WORKSPACE)))

    print(f"Modified {len(changed)} files")
    for f in changed[:40]:
        print(f"  {f}")
    if len(changed) > 40:
        print(f"  ... and {len(changed) - 40} more")
    return 0


if __name__ == "__main__":
    sys.exit(main())

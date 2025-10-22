#! /bin/sh

set -e

if ! buildah version 2>/dev/null; then
  date >"$(hostname)"
  until sudo curl -fsSL "https://github.com/nicholasdille/buildah-static/releases/download/$(curl -fsSL "https://api.github.com/repos/nicholasdille/buildah-static/releases/latest" | grep tag_name | awk -F\" '{print $(NF-1)}')/buildah-$(
    case $(uname -m) in
    x86_64)
      echo amd64
      ;;
    aarch64)
      echo arm64
      ;;
    esac
  ).tar.gz" | tar xz -C /usr/bin --no-same-owner --strip-components=1 "bin/buildah"; do
    sleep "$(($(grep -v ^$ -c "$(hostname)") * 2))s"
    date >>"$(hostname)"
  done
  rm "$(hostname)"
fi

REGISTRY=docker.io
REPOSITORY=muicoder
{
  echo postgres-operator:action
  echo logical-backup:action
} | while read -r repository; do
  echo IyEvYmluL3NoCgpSRUdJU1RSWT0ke1JFR0lTVFJZOi1kb2NrZXIuaW99ClJFUE9TSVRPUlk9JHtSRVBPU0lUT1JZOi1tdWljb2Rlcn0KCkNNRD0kKGlmIHNlYWxvcyA+L2Rldi9udWxsOyB0aGVuIGVjaG8gc2VhbG9zOyBlbGlmIGJ1aWxkYWggPi9kZXYvbnVsbDsgdGhlbiBlY2hvIGJ1aWxkYWg7IGZpKQpNRj0ibWY6JChkYXRlICslRikiCgptYW5pZmVzdCgpIHsKICByZXBvc2l0b3J5PSQxCiAgdGFncz0kMgogIHRhZ0FsbD0kMwogIGVjaG8gIiR0YWdzIiB8IHNlZCAic34sflxufmciIHwgd2hpbGUgcmVhZCAtciB0YWc7IGRvCiAgICBlY2hvICIkUkVHSVNUUlkvJFJFUE9TSVRPUlkvJHJlcG9zaXRvcnk6JHRhZyIKICBkb25lIHwgeGFyZ3MgJENNRCBtYW5pZmVzdCBjcmVhdGUgLS1hbGwgIiRNRiIKICAkQ01EIG1hbmlmZXN0IHB1c2ggIiRNRiIgImRvY2tlcjovLyRSRUdJU1RSWS8kUkVQT1NJVE9SWS8kcmVwb3NpdG9yeTokdGFnQWxsIgogICRDTUQgbWFuaWZlc3Qgcm0gIiRNRiIgfHwgdHJ1ZQp9CgptYW5pZmVzdCAiJHsxOi1rOXN9IiAiJHsyOi1hY3Rpb24tYXJtNjQsYWN0aW9uLWFtZDY0fSIgIiR7Mzotc3RhYmxlfSIK |base64 -d|sh -s ${repository%:*} ${repository#*:} ${1:-v1.10.x}
done

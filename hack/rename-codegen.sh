#!/bin/bash

set -e

codegen=$(grep acid hack/update-codegen.sh | awk -F\" '{print $(NF-1)}')
d_old=$(echo "${codegen% *}" | cut -d: -f1)
o_old=$(echo "${codegen#* }" | cut -d: -f1)
readonly oem=zalan
readonly OEM="${OEM:-$oem}"
echo "OEM: $OEM"
readonly d_new="acid.$OEM.do"
if [ "$OEM" = $oem ]; then
  readonly o_new="${oem}do.org"
else
  readonly o_new="${OEM}.sre"
fi
echo "$d_old=>$d_new"
echo "$o_old=>$o_new"

if [ "$OEM" = $oem ]; then
  exit
fi

toFU() {
  local str firstLetter otherLetter
  str=$1
  firstLetter=$(echo "${str:0:1}" | awk '{print toupper($0)}')
  otherLetter=${str:1}
  echo "$firstLetter$otherLetter"
}

find . -type f | grep $oem | grep -E .go$ | while read -r f; do
  d=${f%/*}
  n=${f##*/}
  D=$(echo "$d" | sed "s~$d_old~$d_new~g;s~$o_old~$o_new~g")
  N=$(echo "$n" | sed "s~$d_old~$d_new~g;s~$o_old~$o_new~g")
  if ! [ -s "$D/$N" ]; then
    mkdir -p "$D"
    sed "s~registry.opensource.zalan.do/acid~docker.io/muicoder~g;s~ghcr.io/zalando~ghcr.io/muicoder~g" <"$f" >"$f.bak" && mv "$f.bak" "$f"
    mv -v "$f" "$D/$N"
  fi
done
grep -rl $oem | grep -E .go$ | while read -r f; do
  sed "s~registry.opensource.zalan.do/acid~docker.io/muicoder~g;s~ghcr.io/zalando~ghcr.io/muicoder~g" <"$f" >"$f.bak" && mv "$f.bak" "$f"
done

{
  grep -rl $oem | grep -E ".(go|mod|Dockerfile)$"
  echo hack/update-codegen.sh
} | while read -r f; do
  sed "s~$d_old~$d_new~g;s~$o_old~$o_new~g;s~/zalando/~/$OEM/~g" <"$f" >"$f.bak" && mv "$f.bak" "$f"
done && chmod a+x hack/update-codegen.sh
cd kubectl-pg
go mod edit -replace "github.com/$OEM/postgres-operator=../" go.mod
cd -

hack/update-codegen.sh && grep '[Zz]alan' -rl | grep -E ".(go|txt)$" | while read -r f; do
  sed "s~Zalando~$(toFU "$OEM")~g;s~zalando~$OEM~g" <"$f" >"$f.bak" && mv "$f.bak" "$f"
done

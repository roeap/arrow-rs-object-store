#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

# This script copies a tarball from the "dev" area of the
# dist.apache.arrow repository to the "release" area
#
# This script should only be run after the release has been approved
# by the arrow PMC committee.
#
# See release/README.md for full release instructions
#
# Based in part on post-01-upload.sh from apache/arrow


set -e
set -u

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_TOP_DIR="$(cd "${SOURCE_DIR}/../../" && pwd)"

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <version> <rc-num>"
  echo "ex. $0 0.4.0 1"
  exit
fi

version=$1
rc=$2

tmp_dir=tmp-apache-arrow-dist

echo "Recreate temporary directory: ${tmp_dir}"
rm -rf ${tmp_dir}
mkdir -p ${tmp_dir}

echo "Clone dev dist repository"
svn \
  co \
  https://dist.apache.org/repos/dist/dev/arrow/apache-arrow-object-store-rs-${version}-rc${rc} \
  ${tmp_dir}/dev

echo "Clone release dist repository"
svn co https://dist.apache.org/repos/dist/release/arrow ${tmp_dir}/release

echo "Copy ${version}-rc${rc} to release working copy"
release_version=arrow-object-store-rs-${version}
mkdir -p ${tmp_dir}/release/${release_version}
cp -r ${tmp_dir}/dev/* ${tmp_dir}/release/${release_version}/
svn add ${tmp_dir}/release/${release_version}

echo "Commit release"
svn ci -m "Apache Arrow Rust Object Store ${version}" ${tmp_dir}/release

echo "Clean up"
rm -rf ${tmp_dir}

echo "Success!"
echo "The release is available here:"
echo "  https://dist.apache.org/repos/dist/release/arrow/${release_version}"

echo "Clean up old artifacts from svn"
"${SOURCE_TOP_DIR}"/dev/release/remove-old-artifacts.sh

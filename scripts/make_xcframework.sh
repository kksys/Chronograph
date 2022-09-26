#!/bin/bash

TARGET_NAME="Chronograph"
TARGET_CONFIG="Release"
OUTPUT_ROOT="build"
ARCHIVE_DIR="${OUTPUT_ROOT}/archives"
LOG_DIR="${OUTPUT_ROOT}/log"
LOGFILE="${LOG_DIR}/make_xcframework-$(date +"%Y%m%d%H%M%S").log"

print_log() {
  echo "[$(date +"%Y/%m/%d %H:%M:%S")] $1"
}

print_log_header() {
  echo "=========================================================" >> ${LOGFILE}
  echo "======             make_xcframework.sh             ======" >> ${LOGFILE}
  echo "=========================================================" >> ${LOGFILE}
  print_log "started." >> ${LOGFILE}
}

archive_target() {
  local PLATFORM=$1
  local SDK=$2
  local OUTPUT="${ARCHIVE_DIR}/${TARGET_NAME}-${PLATFORM// /_}.xcarchive"

  print_log "archive_target is executed..." | tee -a "${LOGFILE}"
  print_log "    PLATFORM = ${PLATFORM}" | tee -a "${LOGFILE}"
  print_log "    SDK = ${SDK}" | tee -a "${LOGFILE}"

  if [ -e "${OUTPUT}" ]; then
    print_log "[WARNING]: This target (platform=\"${PLATFORM}\") is already created..." | tee -a "${LOGFILE}"
    return
  fi

  xcodebuild \
    'ENABLE_BITCODE=YES' \
    'BITCODE_GENERATION_MODE=bitcode' \
    'OTHER_CFLAGS=-fembed-bitcode' \
    'BUILD_LIBRARY_FOR_DISTRIBUTION=YES' \
    'SKIP_INSTALL=NO' \
    archive \
    -project "${TARGET_NAME}.xcodeproj" \
    -scheme "${TARGET_NAME}" \
    -sdk "${SDK}" \
    -destination "generic/platform=${PLATFORM}" \
    -configuration "${TARGET_CONFIG}" \
    -archivePath "${OUTPUT}" >> "${LOGFILE}" 2>&1

  if [ $? -ne 0 ]; then
    local errorcode=$?
    print_log "[ERROR]: xcodebuild is failed." | tee -a "${LOGFILE}"
    exit ${errorcode}
  fi
}

make_xcframework() {
  local OUTPUT_FILE="${TARGET_NAME}.xcframework"
  local OUTPUT_PATH="${OUTPUT_ROOT}/${OUTPUT_FILE}"
  local ARCHIVE_FILE="${TARGET_NAME}.zip"
  local ARCHIVE_PATH="${OUTPUT_ROOT}/${ARCHIVE_FILE}"
  local FRAMEWORK_OPTION=""

  print_log "make_xcframework is executed..." | tee -a "${LOGFILE}"

  while read FRAMEWORK_PATH; do
    FRAMEWORK_OPTION+=" -framework $(echo "${FRAMEWORK_PATH}" | awk '{ gsub("^\.\/", "", $1); print }')"
  done < <(find ./${ARCHIVE_DIR} -name "*.framework" -print)

  xcodebuild \
    -create-xcframework \
    ${FRAMEWORK_OPTION} \
    -output "${OUTPUT_PATH}" >> "${LOGFILE}" 2>&1

  if [ -e "${ARCHIVE_PATH}" ]; then
    rm "${ARCHIVE_PATH}"
  fi

  pushd $(pwd)
  cd ${OUTPUT_ROOT}
  zip -ry "${ARCHIVE_FILE}" "${OUTPUT_FILE}"
  popd
}

make_archive_zip() {
  local ARCHIVE_FILE="${TARGET_NAME}.archive.zip"
  local ARCHIVE_PATH="${OUTPUT_ROOT}/${ARCHIVE_FILE}"

  if [ -e "${ARCHIVE_PATH}" ]; then
    rm "${ARCHIVE_PATH}"
  fi

  pushd $(pwd)
  cd ${ARCHIVE_DIR}
  find . -name "*.xcarchive" -print | xargs zip -ry "${ARCHIVE_FILE}"
  popd

  mv "${ARCHIVE_DIR}/${ARCHIVE_FILE}" "${ARCHIVE_PATH}"
}

main() {
  mkdir -p ${LOG_DIR} && touch "${LOGFILE}"
  print_log_header

  archive_target "iOS" "iphoneos"
  archive_target "iOS Simulator" "iphonesimulator"
  archive_target "macOS" "macosx"

  make_xcframework
  make_archive_zip
}

main

#!/bin/bash
if [[ -z $1 ]]; then
  echo "You need to specify a javascript file"
  echo "Usage: $0 <script> <output>"
  exit 1
fi

if [[ -z $2 ]]; then
  echo "You need to specify an output file"
  echo "Usage: $0 <script> <output>"
  exit 1
fi

OS=$(uname)
INTERPRETER="node"
INTERPRETER_PATH=$(which ${INTERPRETER})
SCRIPT_PATH=$1
if [[ $OS == "Darwin" ]]; then
  INTERPRETER_SIZE=$(stat -f%z ${INTERPRETER_PATH})
  SCRIPT_SIZE=$(stat -f%z ${SCRIPT_PATH})
else 
  INTERPRETER_SIZE=$(du -b ${INTERPRETER_PATH} | grep -oE ^[0-9]+)
  SCRIPT_SIZE=$(du -b ${SCRIPT_PATH} | grep -oE ^[0-9]+)
fi

TOTAL_SIZE=$(expr ${INTERPRETER_SIZE} + ${SCRIPT_SIZE})

echo "Interpreter: ${INTERPRETER_PATH} ${INTERPRETER_SIZE}"
echo "Script: ${SCRIPT_PATH} ${SCRIPT_SIZE}"
echo "Total: ${TOTAL_SIZE}"

TEMP_FILE=$(mktemp)
cat unpacker.template.sh > ${TEMP_FILE}
sed -i -- "s/<TOTAL_SIZE>/${TOTAL_SIZE}/g" ${TEMP_FILE}
sed -i -- "s/<SCRIPT_SIZE>/${SCRIPT_SIZE}/g" ${TEMP_FILE}
sed -i -- "s/<INTERPRETER_SIZE>/${INTERPRETER_SIZE}/g" ${TEMP_FILE}
cat ${TEMP_FILE} ${SCRIPT_PATH} ${INTERPRETER_PATH} > $2
rm ${TEMP_FILE}
chmod +x $2

exit 0

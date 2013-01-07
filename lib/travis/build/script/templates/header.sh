travis_start() {
  echo "travis_start $1"
  echo "`date +%s.%N` [$1:start]" >> <%= LOGS[:state] %>
}

travis_finish() {
  echo "travis_finish $1 ($2)"
  echo "`date +%s.%N` [$1:finish] result: $2" >> <%= LOGS[:state] %>
  sleep 1
}

travis_assert() {
  if [ $? != 0 ]; then
    echo "Command did not exit with 0. Exiting." >> <%= LOGS[:log] %>
    travis_terminate 1
  fi
}

travis_timeout() {
  local pid=$!
  local start=$(date +%s)
  while ps aux | awk '{print $2 }' | grep -q $pid 2> /dev/null; do
    if [ $(expr $(date +%s) - $start) -gt $1 ]; then
      echo "Command timed out after $1 seconds. Exiting." >> <%= LOGS[:log] %>
      travis_terminate 1
    fi
  done
  wait $pid
}

travis_terminate() {
  travis_finish build $1
  pkill -9 -P $$ > /dev/null 2>&1
  exit $1
}

rm -rf   <%= BUILD_DIR %>
mkdir -p <%= BUILD_DIR %>
cd       <%= BUILD_DIR %>

<%= LOGS.map { |name, path| "touch #{path}; > #{path}" }.join("\n") %>

trap 'travis_finish build 1' TERM

travis_start build

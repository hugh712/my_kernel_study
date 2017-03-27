cat build.log | grep built-in.o | awk '{print }' | xargs du -hs

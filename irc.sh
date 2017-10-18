#!/bin/sh

HANDLE='ircsh'
CHAN='#ircsh'
SERVER='irc.freenode.org'
CUE='!ircsh'
REPLY='Hello World!'

mkfifo /tmp/$HANDLE

(
echo HANDLE $HANDLE > /tmp/$HANDLE
echo USER $HANDLE 0 \* : > /tmp/$HANDLE
) &

nc $SERVER 6667 < /tmp/$HANDLE | stdbuf -i0 -o0 tr -d '\r' | while read a b c d e
do
  echo "$a $b $c $d $e" > /dev/null
  test "$a" = PING && echo PONG "$b"
  case "$b" in
    NOTICE )
      if test "$c" = "Auth"
      then
        echo JOIN :$CHAN
      fi
      ;;
    PRIVMSG )
      if test "$d" = ":$CUE"
      then
        echo PRIVMSG $c :$REPLY
      fi
      ;;
  esac
done > /tmp/$HANDLE

wait
rm /tmp/$HANDLE

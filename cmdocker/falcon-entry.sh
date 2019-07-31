#!/bin/sh

DOCKER_DIR=/open-falcon
of_bin=$DOCKER_DIR/open-falcon
DOCKER_HOST_IP=$(route -n | awk '/UG[ \t]/{print $2}')

if [ -z $CORPID ]; then
	CORPID=ww063693cff169b4db
fi

if [ -z $AGENTID ]; then
	AGENTID=1000002
fi

if [ -z $SECRET ]; then
	SECRET=I3NJAv4OX6uhp3nYbwI5h2O3pNwgVZCfEYV3chGTaUo
fi

if [ -z $ENCODING_AES_KEY ]; then
	ENCODING_AES_KEY=K2M3WMhRHIOH4I1Ww5jxpllGrgY01nvBjUgTvcJjjGG
fi

reset_cfg() {
	cp $DOCKER_DIR/wechat/wechat.tpl $DOCKER_DIR/wechat/config.conf

	find $DOCKER_DIR/wechat/config.conf -type f -exec sed -i "s/%%CORPID%%/$CORPID/g" {} \;
	find $DOCKER_DIR/wechat/config.conf -type f -exec sed -i "s/%%AGENTID%%/$AGENTID/g" {} \;
	find $DOCKER_DIR/wechat/config.conf -type f -exec sed -i "s/%%SECRET%%/$SECRET/g" {} \;
	find $DOCKER_DIR/wechat/config.conf -type f -exec sed -i "s/%%ENCODING_AES_KEY%%/$ENCODING_AES_KEY/g" {} \;
}


m=$FALCON_MODULE
if [ ! -f $DOCKER_DIR/$m/config.conf ]; then
	reset_cfg
fi

if [ -z "$SYSLOG_SERVER_PORT" ] ; then
        SYSLOG_SERVER_PORT=514
fi

OPT=
if [ -n "$SYSLOG_SERVER_TCP" ] ; then
        OPT=--tcp
fi

if [ -z "$SYSLOG_SERVER_ADDR" ] ; then
        exec $DOCKER_DIR/$m/falcon-$m  2>&1
        exit 0
else
        exec $DOCKER_DIR/$m/falcon-$m  2>&1 | logger -st falcon-$m --server $SYSLOG_SERVER_ADDR $OPT --port $SYSLOG_SERVER_PORT
        exit 0
fi

#exec "$@"

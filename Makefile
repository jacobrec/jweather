
build:
	ldc weather_read.d -of jweather_read
	ldc weather_sync.d -of jweather_sync

install:
	chmod 511 jweather_sync
	chown root jweather_sync
	mv jweather_sync /bin/jweather_sync
	chmod 511 jweather_read
	chown root jweather_read
	mv jweather_read /bin/jweather_read
	cp ./bash-powerline.sh ~/.bash-powerline.sh

clean:
	rm jweather_sync*
	rm jweather_read*

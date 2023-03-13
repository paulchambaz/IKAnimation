run:
	@processing-java --sketch=IKAnimation --run

build:
	@processing-java --sketch=IKAnimation --output=build --export

install: build
	@mkdir -p /usr/share/IKAnimation
	@cp -r build/* /usr/share/IKAnimation
	@chmod 755 /usr/share/IKAnimation -R
	@printf "#!/bin/bash\ncd /usr/share/IKAnimation && ./IKAnimation\n" > /usr/bin/IKAnimation
	@chmod 755 /usr/bin/IKAnimation

uninstall:
	@rm -fr /usr/share/IKAnimation
	@rm /usr/bin/IKAnimation

clean:
	@rm -fr build

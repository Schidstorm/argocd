


minecraft:
	jsonnet.exe -S -V app=minecraft ./deployment/application.jsonnet | kubectl apply -f -
up:
	./bin/generate_certs.sh
	./bin/generate_kube_config.sh
	./bin/generate_encryption.sh
	docker-compose up -d
	mv ~/.kube/config{,.bak}
	cp conf/admin.yaml ~/.kube/config

clean:
	docker-compose down
	docker-compose rm -f
	rm -f certs/*pem
	rm -f certs/*csr
	rm -f conf/*
	rm -rf /tmp/etcd
	rm -f ~/.kube/config
	mv ~/.kube/config{.bak,}

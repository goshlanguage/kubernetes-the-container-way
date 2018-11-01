up:
	./bin/generate_certs.sh
	./bin/generate_kube_config.sh
	./bin/generate_encryption.sh
	docker-compose up -d

clean:
	docker-compose down
	docker-compose rm -f
	rm -f certs/*pem
	rm -f certs/*csr
	rm -f conf/*
	rm -rf /tmp/etcd

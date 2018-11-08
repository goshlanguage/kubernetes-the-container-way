up:
	./bin/generate_certs.sh
	./bin/generate_kubeconfigs.sh
	./bin/generate_encryption.sh
	docker-compose up -d

clean:
	docker-compose down
	docker-compose rm -f
	rm -f certs/*pem
	rm -f certs/*csr
	rm -f kubeconfig/*
	rm -rf /tmp/etcd

conf:
	mv ~/.kube/kubeconfig{,.bak}
	cp kubeconfig/admin.yaml ~/.kube/config

status:
	kubectl get componentstatuses --kubeconfig ./kubeconfig/admin.yaml
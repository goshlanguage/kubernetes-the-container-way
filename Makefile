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
	kubectl --kubeconfig ./kubeconfig/admin.yaml get componentstatuses
	kubectl --kubeconfig ./kubeconfig/admin.yaml get all --all-namespaces

logs:
	echo "\033[0;32m### API Logs: ###\033[0m\n"
	docker-compose logs kube-apiserver|tail
	echo "\033[0;32m### kube controller-manager Logs: ###\033[0m\n"
	docker-compose logs kube-conrtoller-manager|tail
	echo "\033[0;32m### kube-scheduler Logs: ###\033[0m\n"
	docker-compose logs kube-scheduler|tail
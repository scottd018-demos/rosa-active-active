.PHONY: infra
infra:
	cd infra && \
		terraform init && \
		terraform plan -var-file=main.tfvars -out main.plan && \
		terraform apply main.plan

infra-destroy:
	cd infra && \
		terraform apply -destroy --var-file=main.tfvars

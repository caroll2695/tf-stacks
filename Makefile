SHELL=/bin/bash

.PHONY: init
init:
	terraform init
	
.PHONY: plan
plan:
ifndef env
	@make plan-help
else
	@make plan-valid
endif

.PHONY: plan-valid
plan-valid:
	terraform workspace select $(env)
ifdef target
	terraform plan -var-file=../values/$(env).tfvars $(EXTRA_VAR_FILES) -var-file=./values/$(env).tfvars -target $(target)
else
	terraform plan -var-file=../values/$(env).tfvars $(EXTRA_VAR_FILES) -var-file=./values/$(env).tfvars
endif

.PHONY: plan-help
plan-help:
	@echo "Usage: make plan env=staging|uat|hauat|production|haproduction [options]\n\noptions:\n  target=resource   Target a single resource."

.PHONY: apply
apply:
ifndef env
	@make apply-help
else
	@make apply-valid
endif

.PHONY: apply-valid
apply-valid:
	terraform workspace select $(env)
ifdef target
	terraform apply -var-file=../values/$(env).tfvars $(EXTRA_VAR_FILES) -var-file=./values/$(env).tfvars -target $(target) $(tf_args)
else
	terraform apply -var-file=../values/$(env).tfvars $(EXTRA_VAR_FILES) -var-file=./values/$(env).tfvars $(tf_args)
endif

.PHONY: apply-help
apply-help:
	@echo "Usage: make apply env=staging|uat|hauat|production|haproduction [options]\n\noptions:\n  target=resource   Target a single resource."

.PHONY: refresh
refresh:
ifndef env
	@make refresh-help
else
	@make refresh-valid
endif

.PHONY: refresh-valid
refresh-valid:
	terraform workspace select $(env)
ifdef target
	terraform apply -refresh-only -var-file=../values/$(env).tfvars $(EXTRA_VAR_FILES) -var-file=./values/$(env).tfvars -target $(target)
else
	terraform apply -refresh-only -var-file=../values/$(env).tfvars $(EXTRA_VAR_FILES) -var-file=./values/$(env).tfvars
endif

.PHONY: refresh-help
refresh-help:
	@echo "Usage: make refresh env=staging|uat|hauat|production|haproduction [options]\n\noptions:\n  target=resource   Target a single resource."

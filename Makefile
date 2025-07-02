install:
	pip install --upgrade pip &&\
	pip install -r requirements.txt

format:
	black *.py

train:
	python train.py

eval:
	echo "## Model Metrics" > report.md
	cat ./Results/metrics.txt >> report.md

	echo '\n## Confusion Matrix Plot' >> report.md
	echo '![Confusion Matrix](./Results/model_results.png)' >> report.md

	cml comment create report.md

update-branch:
	git config user.name "$(USER_NAME)"
	git config user.email "$(USER_EMAIL)"
	git add Results/ report.md
	git commit -m "Update: evaluation results" || echo "Nothing to commit"
	git push origin main

deploy:
	@echo "Deploying to Hugging Face Spaces..."
	@echo "Checking HF token..."
	@if [ -z "$(HF_TOKEN)" ]; then \
		echo "❌ Error: HF token is empty!"; \
		echo "Please check that HF_TOKEN secret is set in GitHub repository"; \
		exit 1; \
	else \
		echo "✅ HF token is present"; \
	fi
	pip install huggingface_hub[cli]
	huggingface-cli login --token "$(HF_TOKEN)"
	@echo "🚀 Uploading main app file..."
	huggingface-cli upload firmnnm/MLOpsDrugTest ./app/app.py app.py --repo-type=space --commit-message="Deploy main app file"
	@echo "📁 Uploading model file..."
	huggingface-cli upload firmnnm/MLOpsDrugTest ./model/drug_pipeline.skops model/drug_pipeline.skops --repo-type=space --commit-message="Upload model file"
	@echo "📋 Uploading requirements..."
	huggingface-cli upload firmnnm/MLOpsDrugTest ./requirements.txt requirements.txt --repo-type=space --commit-message="Upload requirements"
	@echo "📄 Uploading README..."
	huggingface-cli upload firmnnm/MLOpsDrugTest ./README.md README.md --repo-type=space --commit-message="Upload README"
	@echo "✅ Deployment completed!"

run:
	python app/app.py

.PHONY: install format test train eval update-branch deploy run

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

	@if command -v cml >/dev/null 2>&1; then \
		echo "Creating CML comment..."; \
		cml comment create report.md; \
	else \
		echo "CML not found. Report saved as report.md"; \
		echo "To use CML comments, install with: npm install -g @dvcorg/cml"; \
	fi

eval-no-cml:
	echo "## Model Metrics" > report.md
	cat ./Results/metrics.txt >> report.md

	echo '\n## Confusion Matrix Plot' >> report.md
	echo '![Confusion Matrix](./Results/model_results.png)' >> report.md
	
	echo "Report generated: report.md"

install-cml:
	npm install -g @dvcorg/cml

check-cml:
	@if command -v cml >/dev/null 2>&1; then \
		echo "✓ CML is installed"; \
		cml --version; \
	else \
		echo "✗ CML is not installed"; \
		echo "Install with: make install-cml"; \
	fi
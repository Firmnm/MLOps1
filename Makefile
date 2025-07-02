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

update-branch:
	@echo "Updating repository with latest results..."
	git config --local user.email "${USER_EMAIL:-action@github.com}"
	git config --local user.name "${USER_NAME:-GitHub Action}"
	git add -A
	git diff --staged --quiet || git commit -m "Update model results and reports [skip ci]"
	git push || echo "Nothing to push"

clean:
	rm -rf __pycache__/
	rm -rf .pytest_cache/
	rm -rf .coverage
	rm -f report.md

help:
	@echo "Available targets:"
	@echo "  install     - Install Python dependencies"
	@echo "  format      - Format code with black"
	@echo "  train       - Train the machine learning model"
	@echo "  eval        - Evaluate model and create report (with CML if available)"
	@echo "  eval-no-cml - Evaluate model without CML"
	@echo "  install-cml - Install CML via npm"
	@echo "  check-cml   - Check if CML is installed"
	@echo "  update-branch - Update git repository with results"
	@echo "  clean       - Clean temporary files"
	@echo "  help        - Show this help message"
# V5 Production Deployment Guide

This directory (`v5_prod`) contains the **pure execution environment** for the Bangladesh Reverse Geocoder. It contains zero development logic and is 100% prepared for production scaling.

## Can I upload this to Hugging Face via GitHub?
**Yes, absolutely.** Hugging Face Spaces natively supports syncing from a GitHub repository. 

However, because your `.bin` files are large (e.g., `sparse_grid.bin` is ~200MB and `master_response_strings.bin` is ~240MB), **you must use Git Large File Storage (Git LFS)** whether you push to GitHub or directly to Hugging Face.

Here are the step-by-step instructions for both methods.

---

### Prerequisites (For both methods)
You need to install `git-lfs` on your computer, as standard Git cannot track files larger than 100MB.

**Mac:**
```bash
brew install git-lfs
git lfs install
```

---

## Method 1: Automated Sync via GitHub Actions (Recommended)
This is the best method if you want to keep your code open-source on GitHub and have Hugging Face automatically update whenever you push to GitHub.

### Step 1: Initialize Git and LFS in `v5_prod`
Open your terminal inside the `v5_prod` folder:
```bash
cd v5_prod
git init
git lfs install

# Tell Git LFS to track all binary data files
git lfs track "*.bin"

# This creates a .gitattributes file. Add it tracking:
git add .gitattributes
```

### Step 2: Commit and Push to GitHub
```bash
git add .
git commit -m "Initial V5 Prod Commit with Sparse Matrices"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
git push -u origin main
```
*Note: The push might take a few minutes depending on your internet speed, as it uploads ~450MB of LFS data.*

### Step 3: Prepare your Hugging Face Space
* Create a new Space on Hugging Face (choose **Docker** > **Blank**).
* **Important:** Hugging Face requires a specific YAML header at the top of your `README.md` to configure the Space. Ensure your GitHub repo's `README.md` includes this header, or your Space won't build.

### Step 4: Get your Hugging Face Token
1. Go to your [Hugging Face Settings > Tokens](https://huggingface.co/settings/tokens).
2. Create a new **Write** token.
3. Copy this token; you’ll need it for GitHub.

### Step 5: Add the Token to GitHub Secrets
1. Go to your repository on GitHub.
2. Click **Settings** > **Secrets and variables** > **Actions**.
3. Click **New repository secret**.
4. Name it `HF_TOKEN` and paste your Hugging Face token as the value.

### Step 6: Create the Sync Workflow
In your GitHub repository, create a new file at `.github/workflows/sync_to_hf.yml` and paste the following code:

```yaml
name: Sync to Hugging Face hub
on:
  push:
    branches: [main]
  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

jobs:
  sync-to-hub:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
          lfs: true
      - name: Push to hub
        env:
          HF_TOKEN: ${{ secrets.HF_TOKEN }}
        run: |
          git push --force https://YOUR_HF_USERNAME:$HF_TOKEN@huggingface.co/spaces/YOUR_HF_USERNAME/YOUR_SPACE_NAME main
```

### ⚠️ Important Edits for the Workflow:
* Replace `YOUR_HF_USERNAME` with your actual Hugging Face username.
* Replace `YOUR_SPACE_NAME` with the name of your Space.
* If your GitHub default branch is `master` instead of `main`, change the last line to `master:main`.

---

## Method 2: Deploying Directly to Hugging Face (Faster Setup)
If you don't want a GitHub repository and just want to host the API immediately.

### Step 1: Create a Space on Hugging Face
1. Go to Hugging Face and click **Create New Space**.
2. Name it (e.g., `bd-reverse-geocoder`).
3. Choose **Docker** as the Space SDK (Blank).
4. Create the Space.

### Step 2: Clone the HF Space and Push
Hugging Face gives you a git link for your Space. In your terminal (outside of `v5_prod`):

```bash
# Clone the empty Hugging Face space
git clone https://huggingface.co/spaces/YOUR_USERNAME/bd-reverse-geocoder
cd bd-reverse-geocoder

# Install LFS for this tracking repo
git lfs install
git lfs track "*.bin"
git add .gitattributes

# Copy everything from v5_prod into this folder
cp -R ../v5_prod/* .

# Push straight to Hugging Face
git add .
git commit -m "Deploy V5 Prod with 0.8ms Lookup"
git push
```

Hugging Face will instantly detect the `Dockerfile`, build the Python 3.11 environment, load the `.bin` matrix into memory, and expose port `7860`. Your API will be live globally!
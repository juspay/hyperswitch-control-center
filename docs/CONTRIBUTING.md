# Contributing

We welcome contributions from the community! If you would like to contribute to Hyperswitch, please follow our contribution guidelines.

### Commit Conventions

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification for our commit messages. Each commit message should have a structured format:

`<type>(<subject>): <description>`

The commit message should begin with one of the following keywords followed by a colon: 'feat', 'fix', 'chore', 'refactor', 'docs', 'test' or 'style'. For example, it should be formatted like this: `feat: <subject> - <description>`

### Signing Commits

All commits should be signed to verify the authenticity of contributors. Follow the steps below to sign your commits:

1.  Generate a GPG key if you haven't already:

    ```bash
    gpg --gen-key
    ```

2.  List your GPG keys and copy the GPG key ID::

    ```bash
    gpg --list-secret-keys --keyid-format LONG
    ```

    #### Identify the GPG key you want to add to your GitHub account.

    a. Run the following command to export your GPG public key in ASCII-armored format:

    ```bash
      gpg --armor --export <GPG_KEY_ID>
    ```

    Replace <GPG_KEY_ID> with the actual key ID.

    b. Copy the entire output, including the lines that start with "-----BEGIN PGP PUBLIC KEY BLOCK-----" and "-----END PGP PUBLIC KEY BLOCK-----".

    c. Go to your GitHub Settings.

    d. Click on "SSH and GPG keys" in the left sidebar.

    e. Click the "New GPG key" button.

    f. Paste your GPG public key into the provided text box.

    g. Click the "Add GPG key" button.

    h. Now your GPG public key is associated with your GitHub account, and you can sign your commits for added security.

3.  Configure Git to use your GPG key:

    ```bash
    git config --global user.signingkey <GPG_KEY_ID>
    ```

4.  Set Git to sign all your commits by default:

    ```bash
    git config --global commit.gpgSign true
    ```

5.  Commit your changes with the -S option to sign the commit:
    ```bash
    git commit -S -m "your commit message"
    ```

For further assistance, please refer to the [GitHub documentation on signing commits](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits).

---

## Standard Process for Raising a Pull Request (PR) from a Branch

### Introduction

Welcome to the standard process for raising a Pull Request (PR) directly from a branch in our project! Please follow these guidelines to ensure that your contributions align with our project's goals and standards.

### Steps to Raise a PR from a Branch

1. **Clone the Repository**:

   - Clone the main repository to your local machine using the following command:
     ```bash
     git clone https://github.com/juspay/hyperswitch-control-center.git
     ```

2. **Create a New Branch**:

   - Create a new branch for your changes directly in the main repository. Please ensure the branch name is descriptive and relates to the feature or bug you're addressing.
     ```bash
     git checkout -b feature/your-feature-name
     ```

3. **Make Changes**:

   - Make the necessary changes in the codebase, ensuring that you follow the project's coding guidelines and standards.

4. **Commit Changes**:

   - Commit your changes with a clear and descriptive commit message. Please follow conventional commit [guidelines](https://www.conventionalcommits.org/).

5. **Push Changes**:

   - Push your changes to the branch in the main repository.
     ```bash
     git push origin feature/your-feature-name
     ```

6. **Create a Pull Request**:

   - Navigate to the main repository on GitHub and create a new PR from your branch. Provide a detailed description of the changes, along with any relevant context or screenshots.

7. **Respond to Feedback**:

   - Be responsive to feedback from reviewers. Address any comments or suggestions promptly and make the necessary changes as required.

### Additional Notes

- Ensure your PR adheres to our coding guidelines, style conventions, and documentation standards.
- Include relevant tests, documentation updates, or screenshots, if applicable.
- Collaborate and communicate effectively with other contributors and maintainers throughout the review process.

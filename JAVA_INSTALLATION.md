# Java Installation Guide

This guide provides instructions for installing Java 23 (Amazon Corretto JDK 23) on different operating systems. The Orion Bot requires Java 23 or higher to run properly.

## Windows

### Automatic Installation (Recommended)

1. Run the included `setup-java.bat` script in the project directory.
2. The script will automatically download and install Amazon Corretto JDK 23.
3. Follow the on-screen instructions during installation.
4. The script will set the JAVA_HOME environment variable automatically.
5. After installation, open a new command prompt and verify the installation by typing:
   ```
   java -version
   ```
   You should see output indicating Java 23 is installed.

### Manual Installation

1. Download Amazon Corretto JDK 23 from the [official website](https://docs.aws.amazon.com/corretto/latest/corretto-23-ug/downloads-list.html).
2. Run the installer and follow the instructions.
3. During installation, make sure to check the option to set the JAVA_HOME environment variable.
4. After installation, open a new command prompt and verify the installation by typing:
   ```
   java -version
   ```
   You should see output indicating Java 23 is installed.

## macOS

1. Download Amazon Corretto JDK 23 for macOS from the [official website](https://docs.aws.amazon.com/corretto/latest/corretto-23-ug/downloads-list.html).
2. Open the downloaded .pkg file and follow the installation instructions.
3. After installation, set the JAVA_HOME environment variable by adding the following lines to your `~/.bash_profile` or `~/.zshrc` file:
   ```bash
   export JAVA_HOME=$(/usr/libexec/java_home -v 23)
   export PATH=$JAVA_HOME/bin:$PATH
   ```
4. Open a new terminal window and verify the installation by typing:
   ```bash
   java -version
   ```
   You should see output indicating Java 23 is installed.

## Linux

### Debian/Ubuntu

1. Download the Amazon Corretto JDK 23 .deb package from the [official website](https://docs.aws.amazon.com/corretto/latest/corretto-23-ug/downloads-list.html).
2. Install the package using the following command:
   ```bash
   sudo dpkg -i amazon-corretto-23-x64-linux-jdk.deb
   ```
   (Replace the filename with the actual downloaded file name)
3. Set the JAVA_HOME environment variable by adding the following lines to your `~/.bashrc` file:
   ```bash
   export JAVA_HOME=/usr/lib/jvm/amazon-corretto-23
   export PATH=$JAVA_HOME/bin:$PATH
   ```
4. Reload your shell configuration:
   ```bash
   source ~/.bashrc
   ```
5. Verify the installation by typing:
   ```bash
   java -version
   ```
   You should see output indicating Java 23 is installed.

### Red Hat/Fedora/CentOS

1. Download the Amazon Corretto JDK 23 .rpm package from the [official website](https://docs.aws.amazon.com/corretto/latest/corretto-23-ug/downloads-list.html).
2. Install the package using the following command:
   ```bash
   sudo rpm -i amazon-corretto-23-x64-linux-jdk.rpm
   ```
   (Replace the filename with the actual downloaded file name)
3. Set the JAVA_HOME environment variable by adding the following lines to your `~/.bashrc` file:
   ```bash
   export JAVA_HOME=/usr/lib/jvm/amazon-corretto-23
   export PATH=$JAVA_HOME/bin:$PATH
   ```
4. Reload your shell configuration:
   ```bash
   source ~/.bashrc
   ```
5. Verify the installation by typing:
   ```bash
   java -version
   ```
   You should see output indicating Java 23 is installed.

## Troubleshooting

### Java Version Not Found

If you see an error like "java: command not found" or if the wrong version of Java is being used:

1. Make sure you've opened a new terminal/command prompt after installation.
2. Verify that JAVA_HOME is set correctly:
   - On Windows: Type `echo %JAVA_HOME%` in Command Prompt
   - On macOS/Linux: Type `echo $JAVA_HOME` in Terminal
3. Verify that Java is in your PATH:
   - On Windows: Type `where java` in Command Prompt
   - On macOS/Linux: Type `which java` in Terminal
4. If JAVA_HOME is not set correctly, set it manually:
   - On Windows: Set it through System Properties > Environment Variables
   - On macOS/Linux: Add it to your shell profile as shown in the installation instructions

### Multiple Java Versions

If you have multiple Java versions installed and need to switch between them:

- On Windows: Use the JAVA_HOME environment variable to point to the correct Java installation.
- On macOS: Use `/usr/libexec/java_home -V` to list available Java versions, then set JAVA_HOME accordingly.
- On Linux: Use alternatives system to manage multiple Java installations:
  ```bash
  sudo update-alternatives --config java
  ```

## Additional Resources

- [Amazon Corretto JDK 23 Documentation](https://docs.aws.amazon.com/corretto/latest/corretto-23-ug/what-is-corretto-23.html)
- [OpenJDK Project](https://openjdk.java.net/)
- [Java SE Documentation](https://docs.oracle.com/en/java/javase/index.html)
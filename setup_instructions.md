# InfoHandler Automated Script Setup

This script automates the process of synchronizing PCG’s VA IEP files to InfoHandler. PCG will need to set up a nightly push of the medicaid export files to their SFTP server. This will need to be requested from PCG. There will be 3 file types \- Students, Goals and Services.

# 

# Requirements

1. Login credentials (username and password) for PCG’s VA IEP SFTP server. This will be the same credentials that you use for your nightly upload of students to PCG.  
2. Login credentials (username and password) for InfoHandler’s SFTP server. These credentials can be obtained from InfoHandler.  
3. A Windows computer that is running during the time that the files are to be uploaded. This needs to be a computer that is not turned off at night since the upload runs at night.  
4. Email credentials for sending confirmation/error emails \- username, password, SMTP server and port number. This can be obtained from your IT department.

# Script Setup

## Package Extract

Extract the contents of the zip file to a folder on the computer that will be running the process. There will be several files:

1. **config.txt** \- Contains the SFTP authentication information for the script

2. **RunUpload.bat** \- Performs the file synchronization. It will be run on a schedule in a later step. Do not modify this file  
3. **sendmail.exe** \- Utility to send email confirmations

4. **sendmail.ini \-** Contains configuration information for email

5. **mail\_success.txt, mail\_error.txt** \- Email messages to be sent on success and error

6. **SyncScript.txt \-** Script to synchronize the SFTP sites. Do not modify this file

7. **WinSCP.exe \-** Utility to connect to SFTP server

## Configuration

### SFTP Configuration

Open **config.txt** to add the SFTP credentials for your division. Enter your credentials for each setting. These settings are used to connect to your InfoHandler SFTP account and your PCG SFTP account.

Save the file and close.

### Email Configuration

Open **sendmail.ini** to enter your email credentials. This is used to send a confirmation email upon a successful run or a failure.

Locate the lines for the following variables and update with your credentials. If your division uses Gmail as it’s email provider, as many do, you only need to update the **auth\_username** and **auth\_password** variables.

Save the file and close.

### Running/Scheduling Task

To run the task once, locate the file called ***RunUpload.bat*** and double click. The script will execute and synchronize the the SFTP sites. \*\*Note: On some WIndows 10 machines, you may get a SmartScreen popup. If you do, click ‘Run Anyway’. The file is safe.

The task will need to be scheduled to run nightly. The computer that you schedule it on will need to be turned on at the time you have the task scheduled. If the computer is turned off, the task will not run.

To locate the WIndows Task Scheduler, click on the Start button in the lower left corner of the screen and type *schedule*. The task scheduler will be the first result

Open this app and click on Create Basic Task on the right hand menu.

This will open the Create Task wizard. In the first step give the task a name and a description

Click Next. On the next step choose **Weekly** for the trigger type.

Click Next. The next step lets you choose when you want the task to run. Check the boxes for all the weekdays and choose a time that best suits your district. This should be a time after PCG uploads your files to the SFTP server. This is usually after midnight.

Click Next. Choose **Start a Program**.

Click Next. Click the **Browse** button to locate **RunUpload.bat**.

Click Next. The next screen give a summary of your task. Make sure everything is correct and click Finish.

Your task is now scheduled and will run at the time you selected. You can test the task by clicking on **Task Scheduler Library** on the left side navigation and finding the task that you just created. Click on it, and click on Run on the right hand side navigation
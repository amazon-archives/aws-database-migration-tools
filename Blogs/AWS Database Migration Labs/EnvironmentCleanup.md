# Environment Cleanup
After you’ve completed the Database migration, you can use the following steps to remove the AWS resources that you created in your account to stop incurring costs.
1. Click [here][dms-console] to go to the Database Migration Service (AWS DMS) console.

2. On the left-hand menu click on **Database migration tasks**, and select the migration tasks that you created one at a time.

![\[dms-task1\]](img/EnvCleanup01.png)

3.	Click on the **Actions** button on the right-hand side, and then select **Stop**.

![\[dms-task2\]](img/EnvCleanup02.png)

4.	Confirm that you want to stop the migration task.

![\[dms-task3\]](img/EnvCleanup03.png)

5.	After the status of the migration tasks changes to **Stopped**, click on the **Actions** button again, and then select **Delete**.

![\[dms-task4\]](img/EnvCleanup04.png)

6.	Confirm that you want to delete the migration task.

![\[dms-task5\]](img/EnvCleanup05.png)

7.	Still in the Database Migration Service console, click on **Endpoints** in the left-hand menu

8. Select the endpoints that you created as a part of the workshop. Then, click on the **Actions** button on the right-hand side, and choose **Delete**. 

![\[dms-endpoint1\]](img/EnvCleanup06.png)

9. Confirm that you want to delete the endpoints.
![\[dms-endpoint2\]](img/EnvCleanup07.png)

10.	Still in the Database Migration Service console, click on **Replication instances** in the left-hand menu

11.	Select the replication instance that you created as a part of the workshop. Then, click on the **Actions** button on the right-hand side, and choose **Delete**.

![\[dms-replicaiton1\]](img/EnvCleanup08.png)

12.	Confirm that you want to delete the replication instance.

![\[dms-replicaiton2\]](img/EnvCleanup09.png)

13.	Next, go to the CloudFormation [console][cfn-console], and click select the **CloudFormation Stack** that you created during the workshop. 

14.	Click on the **Delete** button from the top right corner. CloudFormation will automatically remove all resources that it launched earlier. This process can take up to 15 minutes. 

![\[cfn-stack1\]](img/EnvCleanup10.png)
  
15.	Confirm that you want to delete the stack.

![\[cfn-stack2\]](img/EnvCleanup11.png)

16.	Check the CloudFormation console to ensure the stack that you selected is removed.  

You have completed removing the AWS resources that you deployed earlier from your account.

[dms-console]: https://console.aws.amazon.com/dms/
[cfn-console]: https://console.aws.amazon.com/cloudformation/

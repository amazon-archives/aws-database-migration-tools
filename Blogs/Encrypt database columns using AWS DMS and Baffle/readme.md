# How to encrypt database columns with no impact on your application using AWS DMS and Baffle

# Overview
This template includes the following:

• A MySQL 5.7 database on an Amazon EC2 instance that contains sample sensitive data
• A BaffleShield installation ready for customization
• An RDS MySQL instance to serve as the migration target
• A DMS replication instance to perform the migration

In this blog post, we go over how to use Baffle’s Advanced Data Protection solution to encrypt the databases that you are migrating to RDS. Baffle’s approach helps ensure that your data is never unprotected, whether in memory or at rest, while it’s in the cloud. As you read through it, you will see that there’s virtually no change to the standard DMS migration workflow.

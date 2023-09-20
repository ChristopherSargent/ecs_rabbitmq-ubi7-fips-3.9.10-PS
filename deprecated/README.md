# README for Docker Image builds

## General Setup
This repository is setup for a Jenkins CI/CD pipeline that will automaticlly build the image and create the AWS ECR repository for your image upon git push.

## Folder Layout
The root folder of this repository should house everything your image needs for docker to build it.
#### Do Not Modify or move the Jenkins folder.
#### This folder is for jenkins's use. It contains all the logic for the job to build your image and ECR repository.

## New Build First Deployment
With a new repo and first time build you will need to open up Jenkins/Jenkinsfile and modify line 2. The name of the image needs to match the name of this repository
You do not know how to craete the jenkins job please reach out to Adam Crane, a.crane-ctr@ecstech.com)

## Versioning
This repository handles versioning for you. The versioning is setup with MAJOR.MINOR.PATCH numbering structure. This numbering is handled by the Jenkins job. You just need to tell jenkins how you want to change the version number.
To do this you need to tag your changes.

### Acceptable tags:
* MAJOR will move the first number up one. For example if the current version was 1.2.0 this would change the version to 2.0.0
* MINOR this will move the second number up one. For example if the current version was 1.2.0 this would change the version to 1.3.0
* PATCH this will move the last number up one. For example if the current version was 1.2.0 this would change the version to 1.2.3
* If you do not provide a tag jenkins will reuse the current version when it builds. This will override your existing image in the repository
#### You should only provide 1 of these tags to a commit, as a change can not be more than one of these.

## How to push
* Add all your changes to be commited: git add *
* Make your commit and provide message explaining what has changed: git commit -m 'YOUR MESSAGE HERE'
* (optional)Tag your commit to change the version: git tag -a -m 'YOUR TAG MESSAGE HERE' 'YOUR TAG' (See section above of allowed tags)
* To push changes: git push --follow-tags

### Push Example
```
root@ECS-42V9K13:# git add *
root@ECS-42V9K13:# git commit -m 'updating python pip module' 
[master f97df71] updating jenkins commit logic 
Committer: adam.crane <root@ECS-42V9K13.ecs.local> 
 1 file changed, 1 insertion(+), 1 deletion(-)
root@ECS-42V9K13:# git tag -a -m 'updating pip' 'MINOR'
root@ECS-42V9K13:# git push --follow-tags
Enumerating objects: 6, done.
Counting objects: 100% (6/6), done.
Delta compression using up to 8 threads Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 462 bytes | 15.00 KiB/s, done. Total 4 (delta 2), reused 0 (delta 0)
To https://bitbucket.cdmdashboard.com/scm/cw/jenkins-agent-dev.git
bbd02ff..f97df71  master -> master
 * [new tag]  MINOR -> MINOR
```

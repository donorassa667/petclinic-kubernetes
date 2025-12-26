#!/bin/bash
eksctl delete cluster --name petclinic-prod --region eu-north-1
aws ecr delete-repository --repository-name petclinic --region eu-north-1 --force
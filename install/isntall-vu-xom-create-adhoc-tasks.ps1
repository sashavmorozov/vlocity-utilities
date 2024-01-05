##############DEPLOY###############

#view all orgs
sf org list

#authorize org
sf org login web --instance-url https://login.salesforce.com -a target_org

#deploy Salesforce components
sf project deploy -x .\deployment_descriptors\sf\sf-vu-xom-create-adhoc-tasks.project.xml -o target_org

#deploy Vlocity components
vlocity packDeploy "-sfdx.username" target_org  -job .\deployment_descriptors\vbt\vbt-vu-xom-create-adhoc-tasks.project.yaml



##############RETRIEVE###############

#deploy Salesforce components
sf project retrieve start -x .\deployment_descriptors\sf\sf-vu-xom-create-adhoc-tasks.project.xml -o target_org

#deploy Vlocity components
vlocity packExport "-sfdx.username" target_org  -job .\deployment_descriptors\vbt\vbt-vu-xom-create-adhoc-tasks.project.yaml

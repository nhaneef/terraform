az vm list-skus `
  --location qatarcentral `
  --resource-type virtualMachines `
  --all `
  --query "[?name=='Standard_D8s_v5' || name=='Standard_F8s_v2'].{Name:name,Zones:locationInfo[0].zones}"
  -o table
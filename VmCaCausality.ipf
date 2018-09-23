Function idealizeTrace(timeColumn,dataColumn,scalingFactor,pointNumber)

String timeColumn
String dataColumn
Variable scalingFactor
Variable pointNumber
Variable dim = pointNumber // wavemax($timeColumn)*scalingFactor
String dataColumnId= dataColumn+"id"

wave tCol=$timeColumn
wave dCol=$dataColumn
duplicate/O tCol,tCol_sc
tCol_sc=tCol_sc*scalingFactor
tCol_sc=round(tCol_sc)

make/O/N=(dim) $dataColumnId //dataId
wave dataId=$dataColumnId
dataId=0


Variable i=0
Variable j=0
do 
j=0
if (i>dimsize(dataId,0))
	break
endif

	do
	if (j>dimsize(tCol_sc,0))
		break
	endif
	
	if (i==tCol_sc[j])
		dataId[i]=dCol[j]
	endif
	j=j+1
	while(1)
i=i+1
while(1)



//print max(t_vmpeak)

End


// The function is a fast run-around for the problem of causality
// Computes the "causal points" between Vm and Ca2+
// Does so by normalising the idealised Vm, Ca2+ traces
// Convolves an exponential decay kernel with the Vm data
// the exponential reflects/models the link between Vm and Ca2+
// then computes the product of the convolved wave and Ca2+ data
 
Function convolveVm(VdataName,CadataName,kernelRange,tau)
String VdataName
String CadataName
Variable kernelRange
Variable tau

String CadataNameNorm = CadataName+"_n"
String dataNameConv = Vdataname+"_conv"

make/O/N=(kernelRange) timeexp
timeexp=p
duplicate/O timeexp,xexp
xexp=exp(-timeexp/tau)

duplicate/O $VdataName,$dataNameConv
wave dataConv=$dataNameConv
dataConv=(sign(dataConv-0.01)+1)/2

convolve/A xexp, $dataNameConv

//wave dataConv=$dataNameConv
duplicate/O $CadataName,$CadataNameNorm
wave Cadata=$CadataNameNorm
Cadata=(sign(Cadata-0.01)+1)/2
dataConv=0.5*sign(dataConv-0.01)+0.5
dataConv=dataConv*Cadata

display $dataNameConv

Killwaves/z timeexp,xexp


End

// Contructor for Vm Ca analysis
// important point: Cadata needs to be vs zero not one
// VmDataTime needs to be in seconds (even fractional would do)

Function analyseVmCa(VmDataTime,VmData,CaDataTime,CaData,CaDataS,CaDataRaw)
String VmDataTime
String VmData
String CaDataTime
String CaData
String CaDataS
String CaDataRaw

Variable scalingFactor=1
Variable pointNumber=dimsize($CaDataRaw,0)
String VmDataId = VmData+"id"
String CaDataId = CaData+"id"
String CaDataSId = CaDataS+"id"

Variable kernelRange=10
Variable tau=5

idealizeTrace(VmDataTime,VmData,0.001,pointNumber)
idealizeTrace(CaDataTime,CaData,0.001,pointNumber)
idealizeTrace(CaDataTime,CaDataS,0.001,pointNumber)

convolveVm(VmDataId,CaDataId,kernelRange,tau)
String dataNameConv = VmDataId+"_conv"

String NonZeroVmDataId = VmDataId+"Nz"
String NonZeroCaDataSId = CaDataSId+"Nz"
duplicate/O $dataNameConv,$NonZeroVmDataId
duplicate/O $CaDataSId,$NonZeroCaDataSId
wave nzCaDataSId=$NonZeroCaDataSId
wave nzVmDataId=$NonZeroVmDataId
nzCaDataSId=nzCaDataSId/nzCaDataSId
nzVmDataId=nzVmDataId/nzVmDataId


End

function persistentVariable_indirect
persistent data
tmpData.field1 = 1;
tmpData.field2 = 2;
tmpData.field3 = 3;
tmpData.field4 = 4;
tmpData.field5 = 5;
tmpData.field6 = 6;
tmpData.field7 = 7;
tmpData.field8 = 8;
tmpData.field9 = 9;
tmpData.field10 = 10;
tmpData.field1 = tmpData.field1 * 2;
tmpData.field2 = tmpData.field2 * 2;
tmpData.field3 = tmpData.field3 * 2;
tmpData.field4 = tmpData.field4 * 2;
tmpData.field5 = tmpData.field5 * 2;
tmpData.field6 = tmpData.field6 * 2;
tmpData.field7 = tmpData.field7 * 2;
tmpData.field8 = tmpData.field8 * 2;
tmpData.field9 = tmpData.field9 * 2;
tmpData.field10 = tmpData.field10 * 2;
data = tmpData;
disp(data)
end

     # print("testing exe", selShotDetails[str(aKeys[i])])
        try:
            cursor.execute(curAddStatQuery)            
            checkAt = f'SELECT  AutoTrigger FROM spk_production.`assignment` WHERE AssignmentKey={aKeys[i]};'
            cursor.execute(checkAt)
            resAt = cursor.fetchall()[0]
            # if 3==3:
                        
            if (resAt["AutoTrigger"] == 1 or autoTrigger[str(selShotDetails[aKeys[i]])] == 1 or autoTrigger[str(selShotDetails[aKeys[i]])] == "1"):
                # curShotCompKey = selShotDetails[aKeys[i]]
                
                compq = 'SELECT ShotComponentKey FROM assignment WHERE AssignmentKey={};'.format(aKeys[i])
                # # print(selShotDetails[aKeys[i]])
                cursor.execute(compq)
                comRes = cursor.fetchall()
                curShotCompKey = comRes[0]['ShotComponentKey']
                cur_shotQuery = 'SELECT * FROM shotcomponents where shotComponentKey ='+ str(curShotCompKey)
                cursor.execute(cur_shotQuery)
                cur_shotQueryRes = cursor.fetchall()
                

                cur_shotCompType = cur_shotQueryRes[0]['ShotComponentType'].lower()
                approvedStatusArray = [4, 15, 17, 18]

                # 1.Scenario AssetFix
                if (cur_shotCompType == "assetfix"):
                    remarks_note = "AssetFix APPROVED and moved to Blocking" + " (auto status): "
                    if int(newStatus[i]) in approvedStatusArray:
                        deptQuery = 'SELECT * FROM shotcomponents where ShotKey=(SELECT ShotKey from shotcomponents where shotComponentKey ='+ str(curShotCompKey) + ') ORDER BY ShotComponentKey ASC'
                        cursor.execute(deptQuery)
                        deptQueryRes = cursor.fetchall()

                        otherDeptQueryRes = []
                        for uo_row in deptQueryRes:
                            tmpQueryRes = {}
                            tmpQueryRes['ShotComponentKey'] = uo_row['ShotComponentKey']
                            tmpQueryRes['ShotComponentType'] = uo_row['ShotComponentType']

                            if ((uo_row['ShotComponentType'].lower()) == "assetfix"):
                                # otherDeptQueryRes["0"] =  tmpQueryRes
                                otherDeptQueryRes.insert(0, tmpQueryRes)
                                
                            elif((uo_row['ShotComponentType'].lower()) == "blocking"):
                                # otherDeptQueryRes["1"] =  tmpQueryRes
                                # if ((uo_row['ShotComponentType'].lower()) == "blocking"):
                                otherDeptQueryRes.insert(1, tmpQueryRes)

                            elif((uo_row['ShotComponentType'].lower()) == "qc"):
                                # otherDeptQueryRes["2"] =  tmpQueryRes
                                otherDeptQueryRes.insert(2, tmpQueryRes)

                            elif((uo_row['ShotComponentType'].lower()) == "animation"):
                                # otherDeptQueryRes["2"] =  tmpQueryRes
                                otherDeptQueryRes.insert(3, tmpQueryRes)

                            elif((uo_row['ShotComponentType'].lower()) == "lighting"):
                                # otherDeptQueryRes["3"] =  tmpQueryRes
                                otherDeptQueryRes.insert(4, tmpQueryRes)

                            elif((uo_row['ShotComponentType'].lower()) == "effect"):
                                # otherDeptQueryRes["4"] =  tmpQueryRes
                                otherDeptQueryRes.insert(5, tmpQueryRes)
                            print("tempQueryRes:",tmpQueryRes)
                        #need to sort otherDeptRes
                        
                        arrangedict ={}
                        for other in otherDeptQueryRes:
                            val = other["ShotComponentType"].lower()
                            # if val == 'qc':
                            #     arrangedict['3']=other
                            if val == 'blocking':
                                arrangedict['1']=other
                            elif val == 'animation':
                                arrangedict['2']=other
                            elif val == 'qc':
                                arrangedict['3']=other    
                            elif val == 'lighting':
                                arrangedict['4']=other
                            elif val == 'effect':
                                arrangedict['5']=other
                        # for i in otherDeptQuery:


                        otherDeptQueryRes = [arrangedict.get("1"),arrangedict.get("2"),arrangedict.get("3"),arrangedict.get("4"),arrangedict.get("5")]
                        print('arrangedict',arrangedict)
                        print('OtherDeptQueryRes',otherDeptQueryRes)
                        qcFlag = 1
                        blockingFlag = 0
                        animationFlag = 0
                        lightingFlag = 0
                        qcle = 0 #Qc check for lighting and asset specially
                        department = ""
                        for row in otherDeptQueryRes:
                            if row:
                                otherDeptShotCompKey = row['ShotComponentKey']
                                otherDeptShotCompType = row['ShotComponentType'].lower()
                                if (otherDeptShotCompKey != curShotCompKey):
                                    otherDeptQuery = 'SELECT * FROM assignment left join assignmentstatus on assignment.LatestStatusKey=assignmentstatus.AssignmentStatusKey left join shotcomponents on shotcomponents.shotComponentKey = assignment.ShotComponentKey where assignmentstatus.StatusKey <> 9 and assignment.ShotComponentKey={}'.format(otherDeptShotCompKey)
                                    cursor.execute(otherDeptQuery)
                                    otherDeptQueryRes = cursor.fetchall()
                                    assignmentKey = otherDeptQueryRes[0]['AssignmentKey']
                                    updateBy = otherDeptQueryRes[0]['UpdateBy']
                                    dueDate = otherDeptQueryRes[0]['DueDate']
                                    deptStatusKey = otherDeptQueryRes[0]['StatusKey']
                                    remarks = otherDeptQueryRes[0]['Remarks']
                                    # # print("Remark from : ",remark.splitlines())
                                    department_shotCompType = otherDeptQueryRes[0]['ShotComponentType'].lower()
                                    if (department_shotCompType == "blocking"):
                                    # blocking approved condition
                                        if not (deptStatusKey in approvedStatusArray):  # (!in_array($deptStatusKey, $approvedStatusArray))
                                            remarks_note = "{}  APPROVED and moved to Blocking".format(cur_shotCompType)+ " (auto status)"
                                            lenRemark = len(remarks.splitlines())
                                            if lenRemark <1:
                                                pass
                                            else:
                                                remarks = remarks.splitlines()
                                                remarks[-1] = remarks[-1]+ "(PREVIOUS REMARK)"
                                                remarks = "(PREVIOUS REMARK\n)".join(remarks)

                                            remarks = remarks_note+"\n"+remarks
                                            dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "Blocking")
                                            changedStatusKey = 3
                                            if (dir_submission_check > 0):
                                                changedStatusKey = 3 # DIR_Retake
                                            else:
                                                changedStatusKey = 3 # Lead Note
                                            autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                            autoStatQuery += str(assignmentKey) +  ','+ str(uKey)
                                            autoStatQuery += ', "'+ str(dueDate)+'", "'+ remarks.replace('"', '\\"')+'", '+str(changedStatusKey)+')'
                                            try:
                                                cursor.execute(autoStatQuery)
                                                SPK_addStatus(3, ("Blocking shot updated to DIR Retake"))
                                            except:
                                                SPK_Status.append(SPK_addStatus(3, ("ERROR: Blocking shot failed to update")))
                                            blockingFlag = 1
                                    elif department_shotCompType=="animation":
                                        if ((not deptStatusKey in approvedStatusArray) and (blockingFlag != 1)  ):
                                            checkBlockingApprovedQuery = ""
                                            checkBlockingApprovedRes = ""
                                            remarks_note = "{}  APPROVED and moved to Animation".format(cur_shotCompType) + " (auto status)"
                                            lenRemark = len(remarks.splitlines())
                                            if lenRemark <1:
                                                pass
                                            else:
                                                remarks = remarks.splitlines()
                                                remarks[-1] = remarks[-1]+ "(PREVIOUS REMARK)"
                                                remarks = "(PREVIOUS REMARK\n)".join(remarks)

                                            remarks = remarks_note + "\n" + remarks
                                            dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "Animation")
                                            changedStatusKey = 3
                                            if (dir_submission_check > 0):
                                                changedStatusKey = 3  # DIR_Retake
                                            else:
                                                changedStatusKey = 3  # Lead Note
                                            autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                            autoStatQuery += str(assignmentKey) + ',' + str(uKey)
                                            autoStatQuery += ', "' + str(dueDate) + '", "' + remarks.replace('"','\\"') + '", ' + str(
                                                changedStatusKey) + ')'
                                            try:
                                                cursor.execute(autoStatQuery)
                                                SPK_Status.append(SPK_addStatus(3, ("Animation shot updated to DIR Retake")))
                                            except:
                                                SPK_Status.apped(SPK_addStatus(3, ("ERROR: Animation shot failed to update")))
                                            animationFlag = 1
                                    elif (department_shotCompType == "qc") :
                                    # blocking approved condition
                                        if (not (deptStatusKey in approvedStatusArray) and (blockingFlag != 1) and (qcle != 1) and (animationFlag != 1)):  # (!in_array($deptStatusKey, $approvedStatusArray))
                                            remarks_note = "{}  APPROVED and moved to QC".format(cur_shotCompType)+ " (auto status)"
                                            lenRemark = len(remarks.splitlines())
                                            if lenRemark <1:
                                                pass
                                            else:
                                                remarks = remarks.splitlines()
                                                remarks[-1] = remarks[-1]+ "(PREVIOUS REMARK)"
                                                remarks = "(PREVIOUS REMARK\n)".join(remarks)

                                            remarks = remarks_note+"\n"+remarks
                                            
                                            dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "QC")
                                            changedStatusKey = 3
                                            if (dir_submission_check > 0):
                                                changedStatusKey = 3 # DIR_Retake
                                            else:
                                                changedStatusKey = 3 # Lead Note
                                            autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                            autoStatQuery += str(assignmentKey) +  ','+ str(uKey)
                                            autoStatQuery += ', "'+ str(dueDate)+'", "'+ remarks.replace('"', '\\"')+'", '+str(changedStatusKey)+')'
                                            try:
                                                cursor.execute(autoStatQuery)
                                                SPK_addStatus(3, ("QC shot updated to DIR Retake"))
                                            except:
                                                SPK_Status.append(SPK_addStatus(3, ("ERROR: QC shot failed to update")))
                                            qcFlag = 2
                                            qcle = 1
                                    
                                    
                                    elif department_shotCompType=="lighting":
                                        if ((not deptStatusKey in approvedStatusArray) and (blockingFlag != 1) and (qcle != 1) and (animationFlag != 1)):
                                            remarks_note = "{}  APPROVED and moved to Lighting and Effects".format(cur_shotCompType) + " (auto status)"
                                            lenRemark = len(remarks.splitlines())
                                            if lenRemark <1:
                                                pass
                                            else:
                                                remarks = remarks.splitlines()
                                                remarks[-1] = remarks[-1]+ "(PREVIOUS REMARK)"
                                                remarks = "(PREVIOUS REMARK\n)".join(remarks)

                                            remarks = remarks_note + "\n" + remarks
                                            dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "Lighting")
                                            changedStatusKey = 3
                                            if (dir_submission_check > 0):
                                                changedStatusKey = 3  # DIR_Retake
                                            else:
                                                changedStatusKey = 3  # Lead Note
                                            autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                            autoStatQuery += str(assignmentKey) + ',' + str(uKey)
                                            autoStatQuery += ', "' + str(dueDate) + '", "' + remarks.replace('"',
                                                                                                            '\\"') + '", ' + str(
                                                changedStatusKey) + ')'
                                            try:
                                                cursor.execute(autoStatQuery)
                                                SPK_Status.append(SPK_addStatus(3, ("Lighting shot updated to DIR Retake")))
                                            except:
                                                SPK_Status.append(SPK_addStatus(3, ("ERROR: Lighting shot failed to update")))
                                            lightingFlag = 1
                                        elif deptStatusKey in approvedStatusArray:
                                            remarks_note = "{}  APPROVED and moved to Lighting and Effects".format(
                                                cur_shotCompType) + " (auto status)"
                                            remarks = remarks_note + "\n" + remarks
                                            dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "Lighting")
                                            changedStatusKey = 3
                                            if (dir_submission_check > 0):
                                                changedStatusKey = 3  # DIR_Retake
                                            else:
                                                changedStatusKey = 3  # Lead Note
                                            autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                            autoStatQuery += str(assignmentKey) + ',' + str(uKey)
                                            autoStatQuery += ', "' + str(dueDate) + '", "' + remarks.replace('"',
                                                                                                            '\\"') + '", ' + str(
                                                changedStatusKey) + ')'
                                            try:
                                                cursor.execute(autoStatQuery)
                                                SPK_Status.append(SPK_addStatus(3, ("Lighting shot updated to LEAD NOTE")))
                                            except:
                                                SPK_Status.append(SPK_addStatus(3, ("ERROR: Lighting shot failed to update")))
                                            lightingFlag = 1
                                    elif department_shotCompType == "effect":
                                        if ((not deptStatusKey in approvedStatusArray) and (blockingFlag != 1) and (animationFlag != 1)  and (qcle != 1) and (lightingFlag == 1)):
                                            remarks_note = "{}  APPROVED and moved to Effects and Effects".format(
                                                cur_shotCompType) + " (auto status)"
                                            lenRemark = len(remarks.splitlines())
                                            if lenRemark <1:
                                                pass
                                            else:
                                                remarks = remarks.splitlines()
                                                remarks[-1] = remarks[-1]+ "(PREVIOUS REMARK)"
                                                remarks = "(PREVIOUS REMARK\n)".join(remarks)

                                            remarks = remarks_note + "\n" + remarks
                                            dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "Effects")
                                            changedStatusKey = 3
                                            if (dir_submission_check > 0):
                                                changedStatusKey = 3  # DIR_Retake
                                            else:
                                                changedStatusKey = 3  # Lead Note
                                            autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                            autoStatQuery += str(assignmentKey) + ',' + str(uKey)
                                            autoStatQuery += ', "' + str(dueDate) + '", "' + remarks.replace('"',
                                                                                                            '\\"') + '", ' + str(
                                                changedStatusKey) + ')'
                                            try:
                                                cursor.execute(autoStatQuery)
                                                SPK_Status.append(SPK_addStatus(3, ("Effects shot updated to DIR Retake")))
                                            except:
                                                SPK_Status.append(SPK_addStatus(3, ("ERROR: Effects shot failed to update")))
                                        elif (deptStatusKey in approvedStatusArray):
                                            remarks_note = "{}  APPROVED and moved to Effects and Effects".format(
                                                cur_shotCompType) + " (auto status)"
                                            remarks = remarks_note + "\n" + remarks
                                            dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "Effects")
                                            changedStatusKey = 3
                                            if (dir_submission_check > 0):
                                                changedStatusKey = 3  # DIR_Retake
                                            else:
                                                changedStatusKey = 3  # Lead Note
                                            autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                            autoStatQuery += str(assignmentKey) + ',' + str(uKey)
                                            autoStatQuery += ', "' + str(dueDate) + '", "' + remarks.replace('"','\\"') + '", ' + str(changedStatusKey) + ')'
                                            try:
                                                cursor.execute(autoStatQuery)
                                                SPK_Status.append(SPK_addStatus(3, ("Effects shot updated to DIR Retake")))
                                            except:
                                                SPK_Status.append(SPK_addStatus(3, ("ERROR: Effects shot failed to update")))
                                            lightingFlag = 1
                        
                    if (int(newStatus[i]) == 3):

                        if aType == "Shot":
                            curRem = newRemarks[i].replace('"','\\"')
                            newTask = "AssetFix"
                            newDueDate[i] = newDueDate[i].strip()
                            # # print(newDueDate[i]+'s', type(newDueDate[i]), len(newDueDate[i]))
                            ndate = datetime.datetime.strptime(newDueDate[i], '%Y-%m-%d %H:%M:%S')
                            ndate = ndate + datetime.timedelta(days =2)
                            dueDateStr = SPK_convertToServerDate(request, newDueDate[i])
                            # # print(newDueDate[i], type(newDueDate[i]), type(ndate), ndate,dueDateStr )
                            newAssignTo = 1011
                            keepTN = 0 # keepTaskName
                            keepDD = 0 #keepDD
                            keepST = 0 # keepStatus
                            mObs = 0 # mObs
                            kRM = ''
                            tempTaskName = dept
                            updateQuery = 'UPDATE Assignment SET AssignmentName="'+tempTaskName+'" WHERE AssignmentKey={}'.format(aKeys[i])
                            try:
                                cursor.execute(updateQuery)
                                addStatusQuary = 'insert into AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('+str(aKeys[i])+', '+str(uKey)+', "'+str(nDueDate)+'", "Reassigned", 9 )'
                                try:
                                    cursor.execute(addStatusQuary)
                                    addNewAssignmentQuery = 'INSERT INTO Assignment (AssignmentType, ShotComponentKey, AssignmentName, AssignTo, Priority) VALUES("'+aType + '", '+str(curShotCompKey)+', "'+newTask+'", '+str(newAssignTo)+', 50) '
                                    new_assign_id = ""
                                    try:
                                        cursor.execute(addNewAssignmentQuery)
                                        new_assign_id = cursor.lastrowid
                                        if len(new_assign_id) != 0 :
                                            addStatusQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES('+str(new_assign_id)+', '+str(uKey)+', "'+str(nDueDate)+'", "'+curRem+'",'+newStatus[i]+')'
                                            cursor.execute(addStatusQuary)
                                            context['Abort'] = 0
                                    except:
                                        pass
                                except:
                                    pass
                            except:
                                pass

                # 2.Scenario Blocking
                if (cur_shotCompType == "blocking"):
                    if int(newStatus[i]) in approvedStatusArray:
                        # print('new status in the approver list')
                        # print('shot componet',curShotCompKey)
                        deptQuery = 'SELECT * FROM shotcomponents where ShotKey=(SELECT ShotKey from shotcomponents where shotComponentKey ='+ str(curShotCompKey) + ') ORDER BY ShotComponentKey ASC'
                        cursor.execute(deptQuery)
                        deptQueryRes = cursor.fetchall()
                        print('deptQueries is ',deptQueryRes)

                        otherDeptQueryRes = []
                        """
                         ({'ShotComponentKey': 912967, 'ShotKey': 241306, 'ShotComponentType': 'Blocking'}, {'ShotComponentKey': 912987, 'ShotKey': 241306, 'ShotComponentType': 'Animation'}, {'ShotComponentKey': 913007, 'ShotKey': 241306, 'ShotComponentType': 'Lighting'}, {'ShotComponentKey': 925662, 'ShotKey': 241306, 'ShotComponentType': 'AssetFix'}, {'ShotComponentKey': 925841, 'ShotKey': 241306, 'ShotComponentType': 'Effect'}, {'ShotComponentKey': 951792, 'ShotKey': 241306, 'ShotComponentType': 'Matte'})

                        """
                        for uo_row in deptQueryRes:
                            # print('up row ',uo_row)
                            tmpQueryRes = {}
                            tmpQueryRes['ShotComponentKey'] = uo_row['ShotComponentKey']
                            tmpQueryRes['ShotComponentType'] = uo_row['ShotComponentType']

                            if ((uo_row['ShotComponentType'].lower()) == "assetfix"):
                                # otherDeptQueryRes["0"] =  tmpQueryRes
                                otherDeptQueryRes.insert(0, tmpQueryRes)
                                # print('Assetfix called')
                            elif((uo_row['ShotComponentType'].lower()) == "blocking"):
                                # otherDeptQueryRes["1"] =  tmpQueryRes
                                otherDeptQueryRes.insert(1, tmpQueryRes)
                                # print('Blocking is called',otherDeptQueryRes)

                            elif((uo_row['ShotComponentType'].lower()) == "animation"):
                                # otherDeptQueryRes["2"] =  tmpQueryRes
                                otherDeptQueryRes.insert(2, tmpQueryRes)

                            elif((uo_row['ShotComponentType'].lower()) == "qc"):
                                # otherDeptQueryRes["2"] =  tmpQueryRes
                                otherDeptQueryRes.insert(3, tmpQueryRes)    

                            elif((uo_row['ShotComponentType'].lower()) == "lighting"):
                                # otherDeptQueryRes["3"] =  tmpQueryRes
                                otherDeptQueryRes.insert(4, tmpQueryRes)

                            elif((uo_row['ShotComponentType'].lower()) == "effect"):
                                # otherDeptQueryRes["4"] =  tmpQueryRes
                                otherDeptQueryRes.insert(5, tmpQueryRes)
                        # # print(otherDeptQuery)
                        arrangedict ={}       
                        for other in otherDeptQueryRes:
                            val = other["ShotComponentType"].lower()
                            if val == 'qc':
                                arrangedict['3']=other
                            elif val == 'blocking':
                                arrangedict['1']=other
                            elif val == 'animation':
                                arrangedict['2']=other
                            elif val == 'lighting':
                                arrangedict['4']=other
                            elif val == 'effect':
                                arrangedict['5']=other
                        #need to sort otherDeptRes
                        # # print('other deprttement', otherDeptQuery)
                        otherDeptQueryRes = [arrangedict.get("1"),arrangedict.get("2"),arrangedict.get("3"),arrangedict.get("4"),arrangedict.get("5")]
                        #need to sort otherDeptRes
                        # # print('other deprttement', otherDeptQuery)
                        blockingFlag = 0
                        animationFlag = 0
                        qcFlag = 0 
                        lightingFlag = 0
                        for row in otherDeptQueryRes:
                            if row:
                                otherDeptShotCompKey = row['ShotComponentKey']
                                otherDeptShotCompType = row['ShotComponentType'].lower()
                                if (otherDeptShotCompKey != curShotCompKey):
                                    otherDeptQuery = 'SELECT * FROM assignment left join assignmentstatus on assignment.LatestStatusKey=assignmentstatus.AssignmentStatusKey left join shotcomponents on shotcomponents.shotComponentKey = assignment.ShotComponentKey where assignmentstatus.StatusKey <> 9 and assignment.ShotComponentKey={}'.format(otherDeptShotCompKey)
                                    cursor.execute(otherDeptQuery)
                                    otherDeptQueryRes = cursor.fetchall()
                                    assignmentKey = otherDeptQueryRes[0]['AssignmentKey']
                                    updateBy = otherDeptQueryRes[0]['UpdateBy']
                                    dueDate = otherDeptQueryRes[0]['DueDate']
                                    deptStatusKey = otherDeptQueryRes[0]['StatusKey']
                                    remarks = otherDeptQueryRes[0]['Remarks']
                                    department_shotCompType = otherDeptQueryRes[0]['ShotComponentType'].lower()
                                    if (department_shotCompType == "animation"):
                                    # animation approved condition
                                        if not (deptStatusKey in approvedStatusArray):  # (!in_array($deptStatusKey, $approvedStatusArray))
                                            checkBlockingApprovedQuery = ""
                                            checkBlockingApprovedRes = ""
                                            remarks_note = "{}  APPROVED and moved to Animation".format(cur_shotCompType)+ " (auto status)"
                                            lenRemark = len(remarks.splitlines())
                                            if lenRemark <1:
                                                pass
                                            else:
                                                remarks = remarks.splitlines()
                                                remarks[-1] = remarks[-1]+ "(PREVIOUS REMARK)"
                                                remarks = "(PREVIOUS REMARK\n)".join(remarks)

                                            remarks = remarks_note+"\n"+remarks
                                            dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "Animation")
                                            changedStatusKey = 3
                                            if (dir_submission_check > 0):
                                                changedStatusKey = 3 # DIR_Retake
                                            else:
                                                changedStatusKey = 3 # Lead Note
                                            autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                            autoStatQuery += str(assignmentKey) +  ','+ str(uKey)
                                            autoStatQuery += ', "'+ str(dueDate)+'", "'+ remarks.replace('"', '\\"')+'", '+str(changedStatusKey)+')'
                                            try:
                                                cursor.execute(autoStatQuery)
                                                SPK_Status.append(SPK_addStatus(3, ("Animation shot updated to DIR Retake")))
                                            except:
                                                SPK_Status.append(SPK_addStatus(3, ("ERROR: Animation shot failed to update")))
                                            animationFlag = 1
                                    elif (department_shotCompType == "qc") :
                                    # blocking approved condition
                                        if (not (deptStatusKey in approvedStatusArray) and (animationFlag != 1)):  # (!in_array($deptStatusKey, $approvedStatusArray))
                                            remarks_note = "{}  APPROVED and moved to QC".format(cur_shotCompType)+ " (auto status)"
                                            lenRemark = len(remarks.splitlines())
                                            if lenRemark <1:
                                                pass
                                            else:
                                                remarks = remarks.splitlines()
                                                remarks[-1] = remarks[-1]+ "(PREVIOUS REMARK)"
                                                remarks = "(PREVIOUS REMARK\n)".join(remarks)

                                            remarks = remarks_note+"\n"+remarks
                                            
                                            dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "QC")
                                            changedStatusKey = 3
                                            if (dir_submission_check > 0):
                                                changedStatusKey = 3 # DIR_Retake
                                            else:
                                                changedStatusKey = 3 # Lead Note
                                            autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                            autoStatQuery += str(assignmentKey) +  ','+ str(uKey)
                                            autoStatQuery += ', "'+ str(dueDate)+'", "'+ remarks.replace('"', '\\"')+'", '+str(changedStatusKey)+')'
                                            try:
                                                cursor.execute(autoStatQuery)
                                                SPK_addStatus(3, ("QC shot updated to DIR Retake"))
                                            except:
                                                SPK_Status.append(SPK_addStatus(3, ("ERROR: QC shot failed to update")))
                                            qcFlag = 1
                                                   
                                    elif department_shotCompType=="lighting":
                                        if ((not deptStatusKey in approvedStatusArray) and (animationFlag != 1) and (qcFlag != 1)):

                                            remarks_note = "{}  APPROVED and moved to Lighting and Effect".format(cur_shotCompType) + " (auto status)"
                                            lenRemark = len(remarks.splitlines())
                                            if lenRemark <1:
                                                pass
                                            else:
                                                remarks = remarks.splitlines()
                                                remarks[-1] = remarks[-1]+ "(PREVIOUS REMARK)"
                                                remarks = "(PREVIOUS REMARK\n)".join(remarks)

                                            remarks = remarks_note + "\n" + remarks
                                            dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "Lighting")
                                            changedStatusKey = 3
                                            if (dir_submission_check > 0):
                                                changedStatusKey = 3  # DIR_Retake
                                            else:
                                                changedStatusKey = 3  # Lead Note
                                            autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                            autoStatQuery += str(assignmentKey) + ',' + str(uKey)
                                            autoStatQuery += ', "' + str(dueDate) + '", "' + remarks.replace('"','\\"') + '", ' + str(
                                                changedStatusKey) + ')'
                                            try:
                                                cursor.execute(autoStatQuery)
                                                SPK_Status.append(SPK_addStatus(3, ("Lighting shot updated to LEAD NOTE")))
                                            except:
                                                SPK_Status.append(SPK_addStatus(3, ("ERROR: Lighting shot failed to update")))
                                            lightingFlag = 1
                                        elif deptStatusKey in approvedStatusArray:
                                            remarks_note = "{}  APPROVED and moved to Lighting and Effects".format(
                                                cur_shotCompType) + " (auto status)"
                                            remarks = remarks_note + "\n" + remarks
                                            dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "Lighting")
                                            changedStatusKey = 3
                                            if (dir_submission_check > 0):
                                                changedStatusKey = 3  # DIR_Retake
                                            else:
                                                changedStatusKey = 3  # Lead Note
                                            autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                            autoStatQuery += str(assignmentKey) + ',' + str(uKey)
                                            autoStatQuery += ', "' + str(dueDate) + '", "' + remarks.replace('"',
                                                                                                            '\\"') + '", ' + str(
                                                changedStatusKey) + ')'
                                            try:
                                                cursor.execute(autoStatQuery)
                                                SPK_Status.append(SPK_addStatus(3, ("Lighting shot updated to DIR Retake")))
                                            except:
                                                SPK_Status.append(SPK_addStatus(3, ("ERROR: Lighting shot failed to update")))
                                            lightingFlag = 1
                                    elif department_shotCompType == "effect":
                                        if ((not deptStatusKey in approvedStatusArray)  and (
                                                animationFlag != 1) and (lightingFlag == 1)):
                                            remarks_note = "{}  APPROVED and moved to Effects and Effects".format(
                                                cur_shotCompType) + " (auto status)"
                                            lenRemark = len(remarks.splitlines())
                                            if lenRemark <1:
                                                pass
                                            else:
                                                remarks = remarks.splitlines()
                                                remarks[-1] = remarks[-1]+ "(PREVIOUS REMARK)"
                                                remarks = "(PREVIOUS REMARK\n)".join(remarks)

                                            remarks = remarks_note + "\n" + remarks
                                            dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "Effects")
                                            changedStatusKey = 3
                                            if (dir_submission_check > 0):
                                                changedStatusKey = 3  # DIR_Retake
                                            else:
                                                changedStatusKey = 3  # Lead Note
                                            autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                            autoStatQuery += str(assignmentKey) + ',' + str(uKey)
                                            autoStatQuery += ', "' + str(dueDate) + '", "' + remarks.replace('"',
                                                                                                            '\\"') + '", ' + str(
                                                changedStatusKey) + ')'
                                            try:
                                                cursor.execute(autoStatQuery)
                                                SPK_Status.append(SPK_addStatus(3, ("Effects shot updated to LEAD NOTE")))
                                            except:
                                                SPK_Status.append(SPK_addStatus(3, ("ERROR: Effects shot failed to update")))
                                        elif (deptStatusKey in approvedStatusArray):
                                            remarks_note = "{}  APPROVED and moved to Effects and Effects".format(
                                                cur_shotCompType) + " (auto status)"
                                            remarks = remarks_note + "\n" + remarks
                                            dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "Effects")
                                            changedStatusKey = 3
                                            if (dir_submission_check > 0):
                                                changedStatusKey = 3  # DIR_Retake
                                            else:
                                                changedStatusKey = 3  # Lead Note
                                            autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                            autoStatQuery += str(assignmentKey) + ',' + str(uKey)
                                            autoStatQuery += ', "' + str(dueDate) + '", "' + remarks.replace('"',
                                                                                                            '\\"') + '", ' + str(
                                                changedStatusKey) + ')'
                                            try:
                                                cursor.execute(autoStatQuery)
                                                SPK_Status.append(SPK_addStatus(3, ("Effects shot updated to DIR Retake")))
                                            except:
                                                SPK_Status.append(SPK_addStatus(3, ("ERROR: Effects shot failed to update")))

                
                #3. Scenario Animation
                if (cur_shotCompType == "animation"):
                    # print("animation called")
                    if int(newStatus[i]) in approvedStatusArray:
                        deptQuery = 'SELECT * FROM shotcomponents where ShotKey=(SELECT ShotKey from shotcomponents where shotComponentKey ='+ str(curShotCompKey) + ') ORDER BY ShotComponentKey ASC'
                        cursor.execute(deptQuery)
                        deptQueryRes = cursor.fetchall()

                        otherDeptQueryRes = []
                        for uo_row in deptQueryRes:
                            tmpQueryRes = {}
                            tmpQueryRes['ShotComponentKey'] = uo_row['ShotComponentKey']
                            tmpQueryRes['ShotComponentType'] = uo_row['ShotComponentType']

                            if ((uo_row['ShotComponentType'].lower()) == "assetfix"):
                                # otherDeptQueryRes["0"] =  tmpQueryRes
                                otherDeptQueryRes.insert(0, tmpQueryRes)
                            elif((uo_row['ShotComponentType'].lower()) == "blocking"):
                                # otherDeptQueryRes["1"] =  tmpQueryRes
                                otherDeptQueryRes.insert(1, tmpQueryRes)

                            elif((uo_row['ShotComponentType'].lower()) == "animation"):
                                # otherDeptQueryRes["2"] =  tmpQueryRes
                                otherDeptQueryRes.insert(2, tmpQueryRes)
                            elif((uo_row['ShotComponentType'].lower()) == "qc"):
                                # otherDeptQueryRes["2"] =  tmpQueryRes
                                otherDeptQueryRes.insert(3, tmpQueryRes)    

                            elif((uo_row['ShotComponentType'].lower()) == "lighting"):
                                # otherDeptQueryRes["3"] =  tmpQueryRes
                                otherDeptQueryRes.insert(4, tmpQueryRes)

                            elif((uo_row['ShotComponentType'].lower()) == "effect"):
                                # otherDeptQueryRes["4"] =  tmpQueryRes
                                otherDeptQueryRes.insert(5, tmpQueryRes)
                        
                        #need to sort otherDeptRes
                        blockingFlag = 0
                        animationFlag = 0
                        qcFlag =0
                        lightingFlag = 0
                        for row in otherDeptQueryRes:
                            otherDeptShotCompKey = row['ShotComponentKey']
                            otherDeptShotCompType = row['ShotComponentType'].lower()
                            if (otherDeptShotCompKey != curShotCompKey):
                                otherDeptQuery = 'SELECT * FROM assignment left join assignmentstatus on assignment.LatestStatusKey=assignmentstatus.AssignmentStatusKey left join shotcomponents on shotcomponents.shotComponentKey = assignment.ShotComponentKey where assignmentstatus.StatusKey <> 9 and assignment.ShotComponentKey={}'.format(otherDeptShotCompKey)
                                cursor.execute(otherDeptQuery)
                                otherDeptQueryRes = cursor.fetchall()
                                assignmentKey = otherDeptQueryRes[0]['AssignmentKey']
                                updateBy = otherDeptQueryRes[0]['UpdateBy']
                                dueDate = otherDeptQueryRes[0]['DueDate']
                                deptStatusKey = otherDeptQueryRes[0]['StatusKey']
                                remarks = otherDeptQueryRes[0]['Remarks']
                                department_shotCompType = otherDeptQueryRes[0]['ShotComponentType'].lower()
                                if department_shotCompType == "qc":
                                    # animation approved condition
                                    if (not (deptStatusKey in approvedStatusArray)):  # (!in_array($deptStatusKey, $approvedStatusArray))
                                        remarks_note = "{}  APPROVED and moved to QC".format(cur_shotCompType)+ " (auto status)"
                                        lenRemark = len(remarks.splitlines())
                                        if lenRemark <1:
                                            pass
                                        else:
                                            remarks = remarks.splitlines()
                                            remarks[-1] = remarks[-1]+ "(PREVIOUS REMARK)"
                                            remarks = "(PREVIOUS REMARK\n)".join(remarks)

                                        remarks = remarks_note+"\n"+remarks
                                        
                                        dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "QC")
                                        changedStatusKey = 3
                                        if (dir_submission_check > 0):
                                            changedStatusKey = 3 # DIR_Retake
                                        else:
                                            changedStatusKey = 3 # Lead Note
                                        autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                        autoStatQuery += str(assignmentKey) +  ','+ str(uKey)
                                        autoStatQuery += ', "'+ str(dueDate)+'", "'+ remarks.replace('"', '\\"')+'", '+str(changedStatusKey)+')'
                                        try:
                                            cursor.execute(autoStatQuery)
                                            SPK_addStatus(3, ("QC shot updated to LEAD NOTE"))
                                        except:
                                            SPK_Status.append(SPK_addStatus(3, ("ERROR: QC shot failed to update")))
                                        qcFlag = 1
                                       
                                elif department_shotCompType == "lighting":
                                    if ((not deptStatusKey in approvedStatusArray) and (deptStatusKey != 25) and (qcFlag != 1)):

                                        remarks_note = "{}  APPROVED and moved to Lighting and Effect".format(
                                            cur_shotCompType) + " (auto status)"
                                        lenRemark = len(remarks.splitlines())
                                        if lenRemark <1:
                                            pass
                                        else:
                                            remarks = remarks.splitlines()
                                            remarks[-1] = remarks[-1]+ "(PREVIOUS REMARK)"
                                            remarks = "(PREVIOUS REMARK\n)".join(remarks)

                                        remarks = remarks_note + "\n" + remarks
                                        dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "Lighting")
                                        changedStatusKey = 3
                                        if (dir_submission_check > 0):
                                            changedStatusKey = 3  # DIR_Retake
                                        else:
                                            changedStatusKey = 3  # Lead Note
                                        autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                        autoStatQuery += str(assignmentKey) + ',' + str(uKey)
                                        autoStatQuery += ', "' + str(dueDate) + '", "' + remarks.replace('"',
                                                                                                         '\\"') + '", ' + str(
                                            changedStatusKey) + ')'
                                        try:
                                            cursor.execute(autoStatQuery)
                                            SPK_Status.append(SPK_addStatus(3, ("Lighting shot updated to DIR Retake")))
                                        except:
                                            SPK_Status.append(SPK_addStatus(3, ("ERROR: Lighting shot failed to update")))
                                        lightingFlag = 1
                                    elif ((deptStatusKey in approvedStatusArray) and (deptStatusKey != 25)):
                                        remarks_note = "{}  APPROVED and moved to Lighting and Effects".format(
                                            cur_shotCompType) + " (auto status)"
                                        remarks = remarks_note + "\n" + remarks
                                        dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "Lighting")
                                        changedStatusKey = 3
                                        if (dir_submission_check > 0):
                                            changedStatusKey = 3  # DIR_Retake
                                        else:
                                            changedStatusKey = 3  # Lead Note
                                        autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                        autoStatQuery += str(assignmentKey) + ',' + str(uKey)
                                        autoStatQuery += ', "' + str(dueDate) + '", "' + remarks.replace('"',
                                                                                                         '\\"') + '", ' + str(
                                            changedStatusKey) + ')'
                                        try:
                                            cursor.execute(autoStatQuery)
                                            SPK_Status.append(SPK_addStatus(3, ("Lighting shot updated to LEAD NOTE")))
                                        except:
                                            SPK_Status.append(SPK_addStatus(3, ("ERROR: Lighting shot failed to update")))
                                        lightingFlag = 1
                                elif department_shotCompType == "effect":
                                    # print("Effect under animation called")
                                    if ((not deptStatusKey in approvedStatusArray)  and (deptStatusKey != 25) and (qcFlag != 1) and  (lightingFlag == 1)):
                                        
                                        remarks_note = "{}  APPROVED and moved to Effects".format(
                                            cur_shotCompType) + " (auto status)"
                                        lenRemark = len(remarks.splitlines())
                                        if lenRemark <1:
                                            pass
                                        else:
                                            remarks = remarks.splitlines()
                                            remarks[-1] = remarks[-1]+ "(PREVIOUS REMARK)"
                                            remarks = "(PREVIOUS REMARK\n)".join(remarks)

                                        remarks = remarks_note + "\n" + remarks
                                        dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "Effects")
                                        changedStatusKey = 3
                                        if (dir_submission_check > 0):
                                            changedStatusKey = 3  # DIR_Retake
                                        else:
                                            changedStatusKey = 3  # Lead Note
                                        autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                        autoStatQuery += str(assignmentKey) + ',' + str(uKey)
                                        autoStatQuery += ', "' + str(dueDate) + '", "' + remarks.replace('"',
                                                                                                         '\\"') + '", ' + str(
                                            changedStatusKey) + ')'
                                        try:
                                            cursor.execute(autoStatQuery)
                                            SPK_Status.append(SPK_addStatus(3, ("Effects shot updated to DIR Retake")))
                                        except:
                                            SPK_Status.append(SPK_addStatus(3, ("ERROR: Effects shot failed to update")))
                                    elif ((deptStatusKey in approvedStatusArray) and deptStatusKey != 25):
                                        remarks_note = "{}  APPROVED and moved to Effects and Effects".format(
                                            cur_shotCompType) + " (auto status)"
                                        remarks = remarks_note + "\n" + remarks
                                        dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "Effects")
                                        changedStatusKey = 3
                                        if (dir_submission_check > 0):
                                            changedStatusKey = 3  # DIR_Retake
                                        else:
                                            changedStatusKey = 3  # Lead Note
                                        autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                        autoStatQuery += str(assignmentKey) + ',' + str(uKey)
                                        autoStatQuery += ', "' + str(dueDate) + '", "' + remarks.replace('"',
                                                                                                         '\\"') + '", ' + str(
                                            changedStatusKey) + ')'
                                        try:
                                            cursor.execute(autoStatQuery)
                                            SPK_Status.append(SPK_addStatus(3, ("Effects shot updated to DIR Retake")))
                                        except:
                                            SPK_Status.append(SPK_addStatus(3, ("ERROR: Effects shot failed to update")))

                # 4.Scenario QC
                if (cur_shotCompType == "qc"):
                    # print('qc called')
                    if int(newStatus[i]) in approvedStatusArray:
                        # print('new status in the approver list')
                        # print('shot componet',curShotCompKey)
                        deptQuery = 'SELECT * FROM shotcomponents where ShotKey=(SELECT ShotKey from shotcomponents where shotComponentKey ='+ str(curShotCompKey) + ') ORDER BY ShotComponentKey ASC'
                        cursor.execute(deptQuery)
                        deptQueryRes = cursor.fetchall()
                        # print('deptQueries is ',deptQueryRes)

                        otherDeptQueryRes = []
                        """
                         ({'ShotComponentKey': 912967, 'ShotKey': 241306, 'ShotComponentType': 'Blocking'}, {'ShotComponentKey': 912987, 'ShotKey': 241306, 'ShotComponentType': 'Animation'}, {'ShotComponentKey': 913007, 'ShotKey': 241306, 'ShotComponentType': 'Lighting'}, {'ShotComponentKey': 925662, 'ShotKey': 241306, 'ShotComponentType': 'AssetFix'}, {'ShotComponentKey': 925841, 'ShotKey': 241306, 'ShotComponentType': 'Effect'}, {'ShotComponentKey': 951792, 'ShotKey': 241306, 'ShotComponentType': 'Matte'})

                        """
                        for uo_row in deptQueryRes:
                            # print('up row ',uo_row)
                            tmpQueryRes = {}
                            tmpQueryRes['ShotComponentKey'] = uo_row['ShotComponentKey']
                            tmpQueryRes['ShotComponentType'] = uo_row['ShotComponentType']

                            if ((uo_row['ShotComponentType'].lower()) == "assetfix"):
                                # otherDeptQueryRes["0"] =  tmpQueryRes
                                otherDeptQueryRes.insert(0, tmpQueryRes)
                                # print('Assetfix called')
                            elif((uo_row['ShotComponentType'].lower()) == "blocking"):
                                # otherDeptQueryRes["1"] =  tmpQueryRes
                                otherDeptQueryRes.insert(1, tmpQueryRes)
                                # print('Blocking is called',otherDeptQueryRes)

                            elif((uo_row['ShotComponentType'].lower()) == "animation"):
                                # otherDeptQueryRes["2"] =  tmpQueryRes
                                otherDeptQueryRes.insert(2, tmpQueryRes)

                            elif((uo_row['ShotComponentType'].lower()) == "qc"):
                                # otherDeptQueryRes["2"] =  tmpQueryRes
                                otherDeptQueryRes.insert(3, tmpQueryRes)    

                            elif((uo_row['ShotComponentType'].lower()) == "lighting"):
                                # otherDeptQueryRes["3"] =  tmpQueryRes
                                otherDeptQueryRes.insert(4, tmpQueryRes)

                            elif((uo_row['ShotComponentType'].lower()) == "effect"):
                                # otherDeptQueryRes["4"] =  tmpQueryRes
                                otherDeptQueryRes.insert(5, tmpQueryRes)
                        # # print(otherDeptQuery)
                            
                        arrangedict ={}
                        for other in otherDeptQueryRes:
                            val = other["ShotComponentType"].lower()
                            if val == 'qc':
                                arrangedict['3']=other
                            elif val == 'blocking':
                                arrangedict['1']=other
                            elif val == 'animation':
                                arrangedict['2']=other
                            elif val == 'lighting':
                                arrangedict['4']=other
                            elif val == 'effect':
                                arrangedict['5']=other
                        #need to sort otherDeptRes
                        # # print('other deprttement', otherDeptQuery)
                        otherDeptQueryRes = [arrangedict.get("1"),arrangedict.get("2"),arrangedict.get("3"),arrangedict.get("4"),arrangedict.get("5")]
                        blockingFlag = 0
                        animationFlag = 0
                        lightingFlag = 0
                        animationFlags = 0
                        for row in otherDeptQueryRes:
                            if row:
                                otherDeptShotCompKey = row['ShotComponentKey']
                                otherDeptShotCompType = row['ShotComponentType'].lower()
                                if (otherDeptShotCompKey != curShotCompKey):
                                    otherDeptQuery = 'SELECT * FROM assignment left join assignmentstatus on assignment.LatestStatusKey=assignmentstatus.AssignmentStatusKey left join shotcomponents on shotcomponents.shotComponentKey = assignment.ShotComponentKey where assignmentstatus.StatusKey <> 9 and assignment.ShotComponentKey={}'.format(otherDeptShotCompKey)
                                    cursor.execute(otherDeptQuery)
                                    otherDeptQueryRes = cursor.fetchall()
                                    assignmentKey = otherDeptQueryRes[0]['AssignmentKey']
                                    updateBy = otherDeptQueryRes[0]['UpdateBy']
                                    dueDate = otherDeptQueryRes[0]['DueDate']
                                    deptStatusKey = otherDeptQueryRes[0]['StatusKey']
                                    remarks = otherDeptQueryRes[0]['Remarks']
                                    department_shotCompType = otherDeptQueryRes[0]['ShotComponentType'].lower()
                                    if department_shotCompType=="lighting":
                                        if ((not deptStatusKey in approvedStatusArray)):

                                            remarks_note = "{}  APPROVED and moved to Lighting and Effect".format(cur_shotCompType) + " (auto status)"
                                            lenRemark = len(remarks.splitlines())
                                            if lenRemark <1:
                                                pass
                                            else:
                                                remarks = remarks.splitlines()
                                                remarks[-1] = remarks[-1]+ "(PREVIOUS REMARK)"
                                                remarks = "(PREVIOUS REMARK\n)".join(remarks)

                                            remarks = remarks_note + "\n" + remarks
                                            dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "Lighting")
                                            changedStatusKey = 3
                                            if (dir_submission_check > 0):
                                                changedStatusKey = 3  # DIR_Retake
                                            else:
                                                changedStatusKey = 3  # Lead Note 8
                                            autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                            autoStatQuery += str(assignmentKey) + ',' + str(uKey)
                                            autoStatQuery += ', "' + str(dueDate) + '", "' + remarks.replace('"','\\"') + '", ' + str(
                                                changedStatusKey) + ')'
                                            try:
                                                cursor.execute(autoStatQuery)
                                                SPK_Status.append(SPK_addStatus(3, ("Lighting shot updated to LEAD NOTE")))
                                            except:
                                                SPK_Status.append(SPK_addStatus(3, ("ERROR: Lighting shot failed to update")))
                                            lightingFlag = 1
                                        elif deptStatusKey in approvedStatusArray:
                                            remarks_note = "{}  APPROVED and moved to Lighting and Effects".format(
                                                cur_shotCompType) + " (auto status)"
                                            remarks = remarks_note + "\n" + remarks
                                            dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "Lighting")
                                            changedStatusKey = 3
                                            if (dir_submission_check > 0):
                                                changedStatusKey = 3  # DIR_Retake
                                            else:
                                                changedStatusKey = 3  # Lead Note
                                            autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                            autoStatQuery += str(assignmentKey) + ',' + str(uKey)
                                            autoStatQuery += ', "' + str(dueDate) + '", "' + remarks.replace('"',
                                                                                                            '\\"') + '", ' + str(
                                                changedStatusKey) + ')'
                                            try:
                                                cursor.execute(autoStatQuery)
                                                SPK_Status.append(SPK_addStatus(3, ("Lighting shot updated to LEAD NOTE")))
                                            except:
                                                SPK_Status.append(SPK_addStatus(3, ("ERROR: Lighting shot failed to update")))
                                            lightingFlag = 1
                                    elif department_shotCompType == "effect":
                                        if ((not deptStatusKey in approvedStatusArray) and (lightingFlag == 1)):
                                            remarks_note = "{}  APPROVED and moved to Lighting and Effects".format(
                                                cur_shotCompType) + " (auto status)"
                                            lenRemark = len(remarks.splitlines())
                                            if lenRemark <1:
                                                pass
                                            else:
                                                remarks = remarks.splitlines()
                                                remarks[-1] = remarks[-1]+ "(PREVIOUS REMARK)"
                                                remarks = "(PREVIOUS REMARK\n)".join(remarks)

                                            remarks = remarks_note + "\n" + remarks
                                            dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "Effects")
                                            changedStatusKey = 3
                                            if (dir_submission_check > 0):
                                                changedStatusKey = 3  # DIR_Retake
                                            else:
                                                changedStatusKey = 3  # Lead Note
                                            autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                            autoStatQuery += str(assignmentKey) + ',' + str(uKey)
                                            autoStatQuery += ', "' + str(dueDate) + '", "' + remarks.replace('"',
                                                                                                            '\\"') + '", ' + str(
                                                changedStatusKey) + ')'
                                            try:
                                                cursor.execute(autoStatQuery)
                                                SPK_Status.append(SPK_addStatus(3, ("Effects shot updated to LEAD NOTE")))
                                            except:
                                                SPK_Status.append(SPK_addStatus(3, ("ERROR: Effects shot failed to update")))
                                        elif (deptStatusKey in approvedStatusArray):
                                            remarks_note = "{}  APPROVED and moved to Effects and Effects".format(
                                                cur_shotCompType) + " (auto status)"
                                            remarks = remarks_note + "\n" + remarks
                                            dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "Effects")
                                            changedStatusKey = 3
                                            if (dir_submission_check > 0):
                                                changedStatusKey = 3  # DIR_Retake
                                            else:
                                                changedStatusKey = 3  # Lead Note
                                            autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                            autoStatQuery += str(assignmentKey) + ',' + str(uKey)
                                            autoStatQuery += ', "' + str(dueDate) + '", "' + remarks.replace('"',
                                                                                                            '\\"') + '", ' + str(
                                                changedStatusKey) + ')'
                                            try:
                                                cursor.execute(autoStatQuery)
                                                SPK_Status.append(SPK_addStatus(3, ("Effects shot updated to LEAD NOTE")))
                                            except:
                                                SPK_Status.append(SPK_addStatus(3, ("ERROR: Effects shot failed to update")))
                    
                # 5.Scenario Lighting
                if (cur_shotCompType == "lighting"):
                    # print('animations called')
                    if int(newStatus[i]) in approvedStatusArray:
                        # print('new status in the approver list')
                        # print('shot componet',curShotCompKey)
                        deptQuery = 'SELECT * FROM shotcomponents where ShotKey=(SELECT ShotKey from shotcomponents where shotComponentKey ='+ str(curShotCompKey) + ') ORDER BY ShotComponentKey ASC'
                        cursor.execute(deptQuery)
                        deptQueryRes = cursor.fetchall()
                        # print('deptQueries is ',deptQueryRes)

                        otherDeptQueryRes = []
                        """
                         ({'ShotComponentKey': 912967, 'ShotKey': 241306, 'ShotComponentType': 'Blocking'}, {'ShotComponentKey': 912987, 'ShotKey': 241306, 'ShotComponentType': 'Animation'}, {'ShotComponentKey': 913007, 'ShotKey': 241306, 'ShotComponentType': 'Lighting'}, {'ShotComponentKey': 925662, 'ShotKey': 241306, 'ShotComponentType': 'AssetFix'}, {'ShotComponentKey': 925841, 'ShotKey': 241306, 'ShotComponentType': 'Effect'}, {'ShotComponentKey': 951792, 'ShotKey': 241306, 'ShotComponentType': 'Matte'})

                        """
                        for uo_row in deptQueryRes:
                            # print('up row ',uo_row)
                            tmpQueryRes = {}
                            tmpQueryRes['ShotComponentKey'] = uo_row['ShotComponentKey']
                            tmpQueryRes['ShotComponentType'] = uo_row['ShotComponentType']

                            if ((uo_row['ShotComponentType'].lower()) == "assetfix"):
                                # otherDeptQueryRes["0"] =  tmpQueryRes
                                otherDeptQueryRes.insert(0, tmpQueryRes)
                                # print('Assetfix called')
                            elif((uo_row['ShotComponentType'].lower()) == "blocking"):
                                # otherDeptQueryRes["1"] =  tmpQueryRes
                                otherDeptQueryRes.insert(1, tmpQueryRes)
                                # print('Blocking is called',otherDeptQueryRes)

                            elif((uo_row['ShotComponentType'].lower()) == "animation"):
                                # otherDeptQueryRes["2"] =  tmpQueryRes
                                otherDeptQueryRes.insert(2, tmpQueryRes)

                            elif((uo_row['ShotComponentType'].lower()) == "lighting"):
                                # otherDeptQueryRes["3"] =  tmpQueryRes
                                otherDeptQueryRes.insert(3, tmpQueryRes)

                            elif((uo_row['ShotComponentType'].lower()) == "effect"):
                                # otherDeptQueryRes["4"] =  tmpQueryRes
                                otherDeptQueryRes.insert(4, tmpQueryRes)
                        # # print(otherDeptQuery)
                            

                        #need to sort otherDeptRes
                        # # print('other deprttement', otherDeptQuery)
                        blockingFlag = 0
                        
                        for row in otherDeptQueryRes:
                            otherDeptShotCompKey = row['ShotComponentKey']
                            otherDeptShotCompType = row['ShotComponentType'].lower()
                            if (otherDeptShotCompKey != curShotCompKey and otherDeptShotCompType == "effect"):
                                otherDeptQuery = 'SELECT * FROM assignment left join assignmentstatus on assignment.LatestStatusKey=assignmentstatus.AssignmentStatusKey left join shotcomponents on shotcomponents.shotComponentKey = assignment.ShotComponentKey where assignmentstatus.StatusKey <> 9 and assignment.ShotComponentKey={}'.format(otherDeptShotCompKey)
                                cursor.execute(otherDeptQuery)
                                otherDeptQueryRes = cursor.fetchall()
                                assignmentKey = otherDeptQueryRes[0]['AssignmentKey']
                                updateBy = otherDeptQueryRes[0]['UpdateBy']
                                dueDate = otherDeptQueryRes[0]['DueDate']
                                deptStatusKey = otherDeptQueryRes[0]['StatusKey']
                                remarks = otherDeptQueryRes[0]['Remarks']
                                department_shotCompType = otherDeptQueryRes[0]['ShotComponentType'].lower()
                                if department_shotCompType == "effect":
                                    if (not deptStatusKey in approvedStatusArray):
                                        remarks_note = "{}  APPROVED and moved to  Effects".format(
                                            cur_shotCompType) + " (auto status)"
                                        lenRemark = len(remarks.splitlines())
                                        if lenRemark <1:
                                            pass
                                        else:
                                            remarks = remarks.splitlines()
                                            remarks[-1] = remarks[-1]+ "(PREVIOUS REMARK)"
                                            remarks = "(PREVIOUS REMARK\n)".join(remarks)

                                        remarks = remarks_note + "\n" + remarks
                                        dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "Effects")
                                        changedStatusKey = 3
                                        if (dir_submission_check > 0):
                                            changedStatusKey = 3  # DIR_Retake
                                        else:
                                            changedStatusKey = 3  # Lead Note
                                        autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                        autoStatQuery += str(assignmentKey) + ',' + str(uKey)
                                        autoStatQuery += ', "' + str(dueDate) + '", "' + remarks.replace('"',
                                                                                                         '\\"') + '", ' + str(
                                            changedStatusKey) + ')'
                                        try:
                                            cursor.execute(autoStatQuery)
                                            SPK_Status.append(SPK_addStatus(3, ("Effects shot updated to DIR Retake ")))
                                        except:
                                            SPK_Status.append(SPK_addStatus(3, ("ERROR: Effects shot failed to update")))
                                    elif (deptStatusKey in approvedStatusArray):
                                        remarks_note = "{}  APPROVED and moved to Effects and Effects".format(
                                            cur_shotCompType) + " (auto status)"
                                        lenRemark = len(remarks.splitlines())
                                        if lenRemark <1:
                                            pass
                                        else:
                                            remarks = remarks.splitlines()
                                            remarks[-1] = remarks[-1]+ "(PREVIOUS REMARK)"
                                            remarks = "(PREVIOUS REMARK\n)".join(remarks)

                                        remarks = remarks_note + "\n" + remarks
                                        dir_submission_check = checkDIR_SUBMISSION(aKeys[i], "Effects")
                                        changedStatusKey = 3
                                        if (dir_submission_check > 0):
                                            changedStatusKey = 3  # DIR_Retake
                                        else:
                                            changedStatusKey = 3  # Lead Note
                                        autoStatQuery = 'INSERT INTO AssignmentStatus (AssignmentKey, UpdateBy, DueDate, Remarks, StatusKey) VALUES ('
                                        autoStatQuery += str(assignmentKey) + ',' + str(uKey)
                                        autoStatQuery += ', "' + str(dueDate) + '", "' + remarks.replace('"',
                                                                                                         '\\"') + '", ' + str(
                                            changedStatusKey) + ')'
                                        try:
                                            cursor.execute(autoStatQuery)
                                            SPK_Status.append(SPK_addStatus(3, ("Effects shot updated to DIR Retake")))
                                        except:
                                            SPK_Status.append(SPK_addStatus(3, ("ERROR: Effects shot failed to update")))




% tsiNetworkInterface - Interface class between client and TSI server
%
% Usage:
%   >> obj = tsiNetworkInterface (OutputStream, InputStream)
%
% properties:
%
%
% Author(s): Bruno Direito, Jo?o Lima, Marco Sim?es, IBILI, 12 May 2014

classdef TSINetworkInterface < handle
    
    %% Properties
    properties (SetAccess = private)
        tsiClient
        
    end
    
    
    %% Methods
    methods
        
        % constructor
        function obj = TSINetworkInterface (tsiClient)
            obj.tsiClient = tsiClient;
        end
        
        
        function createConnection(obj)
            obj.tsiClient.createConnection();
        end
        
        function closeConnection(obj)
            obj.tsiClient.closeConnection();
        end
        
        
        % =====================================
        %% TSI server QUERIES
        % =====================================
        
        
        % --------------------
        %% Basic project queries
        % --------------------
        
        function CurrentTimePoint = tGetCurrentTimePoint(obj)
            %   Send: tGetCurrentTimePoint
            %   Receive: int CurrentTimePoint
            %   Provides the number of the currently processed step during real-time processing as an
            %       integer. Note that this function is 1-based, i.e. when the first step is processed the function
            %       returns "1" not "0"; this is important when the return value is used to access time-related
            %       information; in this case subtract "1" from the returned value.
            
            % send request and read message/response
            [rOK, aOK, tResponse]= obj.tsiClient.query('tGetCurrentTimePoint');
            
            %  int CurrentTimePoint
            CurrentTimePoint = double(swapbytes(typecast(tResponse(1:4),'int32')));
            tResponse(1:4) = [];
            %             fprintf(1, '\n - answer received - message: %i \n\n',time_temp);
            
        end
        function NrOfChannels = tGetNrOfChannels(obj)
            %   Send: tGetNrOfChannels
            %   Receive: int NrOfChannels
            %   Provides the number of available channels
            
            [rOK, aOK, tResponse]= obj.tsiClient.query('tGetNrOfChannels' );
            
            % dim_x
            NrOfChannels = double(swapbytes(typecast(tResponse(1:4),'int32')));
            tResponse(1:4) = [];
            
        end   
        function ValuesFeedbackFolder = tGetValuesFeedbackFolder(obj)
            %   Send: tGetValuesFeedbackFolder
            %   Receive: char[100] ValuesFeedbackFolder
            %   Provides the path of the feedback folder for calculated neurofeedback values as a C string; note that
            %       the provided pointer must point to a pre-allocated array that is large enough for the returned path (a
            %       buffer of 513 bytes is recommended). The values feedback folder can be used to store the result of
            %       custom calculations. It is located under the folder containing the protocol specified prior to starting
            %       real-time processing and is usually named ???NeurofeedbackValues".
            
            % send request and read message/response
            [rOK, aOK, tResponse]= obj.tsiClient.query('tGetValuesFeedbackFolder');
            
            
            % message size
            messageSize = double(swapbytes(typecast(tResponse(1:4),'int32')));
            tResponse(1:4) = [];
            
            % char[100] cProjectName
            ValuesFeedbackFolder = char(tResponse);
            
            %             fprintf(1, '\n - answer received - message: %s \n\n', ValuesFeedbackFolder);
        end
        function ImagesFeedbackFolder = tGetImagesFeedbackFolder(obj)
            %   Send: tGetImagesFeedbackFolder
            %   Receive: char[100] ImagesFeedbackFolder
            %   Provides the path of the feedback folder for snapshots of the thermometer display as a C string; note that
            %       the provided pointer must point to a pre-allocated array that is large enough for the returned path (a
            %       buffer of 513 bytes is recommended). The images feedback folder is located under the folder
            %       containing the protocol specified prior to starting real-time processing and is usually named
            %       ???NeurofeedbackImages".
            
            % send request and read message/response
            [rOK, aOK, tResponse]= obj.tsiClient.query('tGetImagesFeedbackFolder');
            
            
            % message size
            messageSize = double(swapbytes(typecast(tResponse(1:4),'int32')));
            tResponse(1:4) = [];
            
            % char[100] cProjectName
            ImagesFeedbackFolder = char(tResponse);
            
            %             fprintf(1, '\n - answer received - message: %s \n\n', ImagesFeedbackFolder);
            
        end
        
        
        % --------------------
        %% Selected Channels Info
        % --------------------
        
        function NrOfSelectedChannels = tGetNrOfSelectedChannels(obj)
            %   Send: tGetNrOfSelectedChannels
            %   Receive: int NrOfSelectedChannels
            %   Provides the number of channels that are currently selected in the GUI. When processing selected
            %       channels (e.g. to average their signals), this function must be called at each time point since it can
            %       change anytime. Inspect the provided ExamplePlugin code for more details.
            
            [rOK, aOK, tResponse]= obj.tsiClient.query('tGetNrOfSelectedChannels' );
            
            % Number of selected channels
            NrOfSelectedChannels = double(swapbytes(typecast(tResponse(1:4),'int32')));
            tResponse(1:4) = [];
            
        end
        function SelectedChannels = tGetSelectedChannels(obj)
            %             Send: tGetSelectedChannels
            %             Receive: int [NrOfSelectedChannels] SelectedChannels
            %             Provides the full time course data to a given time point that is also used internally in TSI.
            %                 Individual values are 2-byte short integers. Note that the "timepoint" parameter must be
            %                 smaller than the value returned by the "tGetCurrentTimePoint()" function. If a voxel with
            %                 specific coordinates needs to be accessed, use the term "z_coord*dim_x*dim_y +
            %                 y_coord*dim_x + x_coord". For details, see the provided example clients.

            [rOK, aOK, tResponse]= obj.tsiClient.query('tGetSelectedChannels');
            
            SelectedChannels = [];
            
            for i=1:(length(tResponse)/4)
                SelectedChannels(i) = double(swapbytes(typecast(tResponse(((i-1)*4)+1:(i*4)),'int32')))+1;
            end
            
        end

        % --------------------
        %% Get Raw Data
        % --------------------   
        function RawDataScaleFactor = tGetRawDataScaleFactor(obj)
            %   Send: tGetRawDataScaleFactor
            %   Receive: int roi
            %   Provides the scale factor set in the GUI to multiply the raw data wavelength values. While not
            %      necessary, It is recommended that accessed data (see below) is multiplied by this value to be
            %      compatible with the values displayed in the GUI. Inspect the provided ExamplePlugin code for more
            %      details.

            % send request and read message/response
            [rOK, aOK, tResponse]= obj.tsiClient.query('tGetRawDataScaleFactor');
            
            % float RawDataScaleFactor
            RawDataScaleFactor = typecast(uint8(tResponse(4:-1:1)), 'single');
            
            % fprintf(1, '\n - answer received - message: ROI # %i, meanvalue - %i \n\n',nrOfROI, meanOfROI);
            
        end        
        function RawDataWL1 = tGetRawDataWL1(obj, chs, frame)
            %   Send: tGetRawDataWL1, int ch, int frame
            %   Receive: int ch, int frame, float RawDataWL1
            %   Provides the value of the raw data for wavelength 1 for the specified channel ???ch???? and the specified
            %       time point ???frame????. If the current values are of interest, ???frame???? should be set to one less the value
            %       obtained by the ???tGetCurrentTimePoint()???? function. To be compatible with the values displayed in the
            %       GUI, it is recommended to multiply the retrieved value by the scale value obtained from the
            %       ???tGetRawDataScaleFactor()???? function.
            
            % define output variable according to user guide
            RawDataWL1 = [];
            for ch = chs
                output(1) = {ch-1};
                output(2) = {frame-1};

                % send request and read message/response
                [rOK, aOK, tResponse]= obj.tsiClient.query('tGetRawDataWL1' , output);

                if numel(tResponse)~=12
                    % Find error
                    if  ~numel(strfind (char(tResponse), 'ch out of range'))==0
                        responseString = char(tResponse(strfind (char(tResponse), 'ch out of range'):end));
                        fprintf(1, '%s. \n', responseString)
                    end
                end


                % int ROI
                ch = double(swapbytes(typecast(tResponse(1:4),'int32'))) + 1; % zero index-based
                tResponse(1:4) = [];

                % int toTimePoint
                frame = double(swapbytes(typecast(tResponse(1:4),'int32'))); % zero index-based
                tResponse(1:4) = [];

                
                % float RawDataWL1
                RawDataWL1(end+1) = double(typecast(uint8(tResponse(4:-1:1)), 'single'));

            end
            %             fprintf(1, '\n - answer received - message: ROI # %i, RawDataWL1 - %i \n\n',ch, RawDataWL1);
            
        end        
        function RawDataWL2 = tGetRawDataWL2(obj, chs, frame)
            %   Send: tGetRawDataWL2, int ch, int frame
            %   Receive: int ch, int frame, float RawDataWL2
            %   Provides the value of the raw data for wavelength 2 for the specified channel ???ch???? and the specified
            %       time point ???frame????. If the current values are of interest, ???frame???? should be set to one less the value
            %       obtained by the ???tGetCurrentTimePoint()???? function. To be compatible with the values displayed in the
            %       GUI, it is recommended to multiply the retrieved value by the scale value obtained from the
            %       ???tGetRawDataScaleFactor()???? function.
            
            RawDataWL2 = [];
            
            for ch = chs
                % define output variable according to user guide
                output(1) = {ch-1};
                output(2) = {frame-1};

                % send request and read message/response
                [rOK, aOK, tResponse]= obj.tsiClient.query('tGetRawDataWL2' , output);

                if numel(tResponse)~=12
                    % Find error
                    if  ~numel(strfind (char(tResponse), 'ch out of range'))==0
                        responseString = char(tResponse(strfind (char(tResponse), 'ch out of range'):end));
                        fprintf(1, '%s. \n', responseString)
                    end
                end


                % int ROI
                ch = swapbytes(typecast(tResponse(1:4),'int32')) + 1; % zero index-based
                tResponse(1:4) = [];

                % int toTimePoint
                frame = swapbytes(typecast(tResponse(1:4),'int32')); % zero index-based
                tResponse(1:4) = [];


                % float RawDataWL2
                RawDataWL2(end+1) = typecast(uint8(tResponse(4:-1:1)), 'single');
            
            end
            %             fprintf(1, '\n - answer received - message: ROI # %i, RawDataWL2 - %i \n\n',ch, RawDataWL1);
            
        end
        
        
        % --------------------
        %% Get Preprocessed Data
        % --------------------        
        function IsDataOxyDeoxyConverted = tIsDataOxyDeoxyConverted(obj)
            %   Send: tIsDataOxyDeoxyConverted
            %   Receive: int IsDataOxyDeoxyConverted
            %   Returns integer ???1???? if oxygenated/deoxygeneated values are requested in the GUI (default) and if
            %       concentration values can be calculated, i.e. after the specified baseline period has passed.
            
            [rOK, aOK, tResponse]= obj.tsiClient.query('tIsDataOxyDeoxyConverted' );
            
            % Number of selected channels
            IsDataOxyDeoxyConverted = double(swapbytes(typecast(tResponse(1:4),'int32')));
            tResponse(1:4) = [];
            
        end    
        function GetOxyDeOxyBaselineEnd = tGetOxyDeOxyBaselineEnd(obj)
            %   Send: GetOxyDeOxyBaselineEnd
            %   Receive: int GetOxyDeOxyBaselineEnd
            %   Returns integer ???1???? specifies the end of the baseline period used to calculated concentration values.
            
            [rOK, aOK, tResponse]= obj.tsiClient.query('tGetOxyDeOxyBaselineEnd' );
            
            % Number of selected channels
            GetOxyDeOxyBaselineEnd = double(swapbytes(typecast(tResponse(1:4),'int32')));
            tResponse(1:4) = [];
            
        end 
        function OxyDataScaleFactor = tGetOxyDataScaleFactor(obj)
            %   Send: tGetOxyDataScaleFactor
            %   Receive: float OxyDataScaleFactor
            %   Provides the scale factor set in the GUI to multiply the preprocessed oxy/deoxy data values. While
            %       not necessary, It is recommended that accessed oxy/deoxy concentration data (see below) is
            %       multiplied by this value to be compatible with the values displayed in the GUI. Inspect the provided
            %       ExamplePlugin code for more details.
            
            % send request and read message/response
            [rOK, aOK, tResponse]= obj.tsiClient.query('tGetOxyDataScaleFactor');
            
            % float RawDataScaleFactor
            OxyDataScaleFactor = double(typecast(uint8(tResponse(4:-1:1)), 'single'));
            
            % fprintf(1, '\n - answer received - message: ROI # %i, meanvalue - %i \n\n',nrOfROI, meanOfROI);
            
        end       
        function DataOxy = tGetDataOxy(obj, chs, frame)
            %   Send: tGetDataOxy, int ch, int frame
            %   Receive: int ch, int frame, float DataOxy
            %   Provides the value of the oxygenated data for the specified channel ???ch???? and the specified time point
            %       ???frame????. If the current values are of interest, ???frame???? should be set to one less the value obtained by
            %       the ???tGetCurrentTimePoint()???? function. To be compatible with the values displayed in the GUI, it is
            %       recommended to multiply the retrieved value by the scale value obtained from the
            %       ???tGetOxyDataScaleFactor()???? function.
            frame = frame-1;
            DataOxy = [];
            for ch = chs
                % define output variable according to user guide
                output(1) = {ch-1};
                output(2) = {frame};

                % send request and read message/response
                [rOK, aOK, tResponse]= obj.tsiClient.query('tGetDataOxy' , output);

                if numel(tResponse)~=12
                    % Find error
                    if  ~numel(strfind (char(tResponse), 'ch out of range'))==0
                        responseString = char(tResponse(strfind (char(tResponse), 'ch out of range'):end));
                        fprintf(1, '%s. \n', responseString)
                    end
                end

                if(length(tResponse) == 0)
                    DataOxy = tGetDataOxy(obj, ch, frame);
                    return;
                end
                % int ROI
    %             ch = swapbytes(typecast(tResponse(1:4),'int32')) + 1; % zero index-based
                tResponse(1:4) = [];

                % int toTimePoint
    %             frame = swapbytes(typecast(tResponse(1:4),'int32')); % zero index-based
                tResponse(1:4) = [];


                % float DataOxy
                DataOxy(end+1) = double(typecast(uint8(tResponse(4:-1:1)), 'single'));
            end
            
            %             fprintf(1, '\n - answer received - message: ROI # %i, DataOxy - %i \n\n',ch, DataOxy);
            
        end       
        function AllDataOxy = tGetAllDataOxy(obj, chs, frame)
            %   Send: tGetAllDataOxy, int ch, int frame
            %   Receive: int ch, int frame, float AllDataOxy
            %   Provides the value of the oxygenated data for the specified channel ???ch???? and the specified time point
            %       ???frame????. If the current values are of interest, ???frame???? should be set to one less the value obtained by
            %       the ???tGetCurrentTimePoint()???? function. To be compatible with the values displayed in the GUI, it is
            %       recommended to multiply the retrieved value by the scale value obtained from the
            %       ???tGetOxyDataScaleFactor()???? function.
            
            AllDataOxy = 0;
            frame = frame;
            for ch = chs
                
                % define output variable according to user guide
                output(1) = {ch-1};
                output(2) = {frame};

                % send request and read message/response
                [rOK, aOK, tResponse]= obj.tsiClient.query('tGetAllDataOxy' , output);

                if numel(tResponse)~=12
                    % Find error
                    if  ~numel(strfind (char(tResponse), 'ch out of range'))==0
                        responseString = char(tResponse(strfind (char(tResponse), 'ch out of range'):end));
                        fprintf(1, '%s. \n', responseString)
                    end
                end

                if(length(tResponse) == 0)
                    AllDataOxy = tGetAllDataOxy(obj, ch, frame);
                    return;
                end
                % int ROI
                 ch = double(swapbytes(typecast(tResponse(1:4),'int32'))) + 1; % zero index-based
                tResponse(1:4) = [];

                % int toTimePoint
                 frame = double(swapbytes(typecast(tResponse(1:4),'int32'))); % zero index-based
                tResponse(1:4) = [];



                tResp_swap = swapbytes(tResponse);
                data = [];
                data = double(swapbytes(typecast(tResp_swap, 'single')));
                if AllDataOxy == 0
                    AllDataOxy = data;
                else
                    AllDataOxy = [AllDataOxy;data];
                end

            end
            
            %             fprintf(1, '\n - answer received - message: ROI # %i, DataOxy - %i \n\n',ch, DataOxy);
            
        end    
        function DataDeOxy = tGetDataDeOxy(obj, chs, frame)
            %   Send: tGetDataDeOxy, int ch, int frame
            %   Receive: int ch, int frame, float DataDeoxy
            %   Provides the value of the deoxygenated data for the specified channel ???ch???? and the specified time
            %       point ???frame????. If the current values are of interest, ???frame???? should be set to one less the value
            %       obtained by the ???tGetCurrentTimePoint()???? function. To be compatible with the values displayed in the
            %       GUI, it is recommended to multiply the retrieved value by the scale value obtained from the
            %       ???tGetOxyDataScaleFactor()???? function.
            frame = frame-1;
            DataDeOxy = [];
            for ch = chs
                
                % define output variable according to user guide
                output(1) = {ch-1};
                output(2) = {frame};

                % send request and read message/response
                [rOK, aOK, tResponse]= obj.tsiClient.query('tGetDataDeOxy' , output);

                if numel(tResponse)~=12
                    % Find error
                    if  ~numel(strfind (char(tResponse), 'ch out of range'))==0
                        responseString = char(tResponse(strfind (char(tResponse), 'ch out of range'):end));
                        fprintf(1, '%s. \n', responseString)
                    end
                end
                ch = double(swapbytes(typecast(tResponse(1:4),'int32'))) + 1; % zero index-based
                tResponse(1:4) = [];

                frame = double(swapbytes(typecast(tResponse(1:4),'int32'))); % zero index-based
                tResponse(1:4) = [];
                DataDeOxy(end+1) = double(typecast(uint8(tResponse(4:-1:1)), 'single'));
            end
        end 
        function AllDataDeOxy = tGetAllDataDeOxy(obj, chs, frame)
            %   Send: tGetAllDataOxy, int ch, int frame
            %   Receive: int ch, int frame, float AllDataOxy
            %   Provides the value of the oxygenated data for the specified channel ???ch???? and the specified time point
            %       ???frame????. If the current values are of interest, ???frame???? should be set to one less the value obtained by
            %       the ???tGetCurrentTimePoint()???? function. To be compatible with the values displayed in the GUI, it is
            %       recommended to multiply the retrieved value by the scale value obtained from the
            %       ???tGetOxyDataScaleFactor()???? function.
            frame = frame;
            AllDataDeOxy = 0;
            for ch = chs
                % define output variable according to user guide
                output(1) = {ch-1};
                output(2) = {frame};

                % send request and read message/response
                [rOK, aOK, tResponse]= obj.tsiClient.query('tGetAllDataDeOxy' , output);

                if numel(tResponse)~=12
                    % Find error
                    if  ~numel(strfind (char(tResponse), 'ch out of range'))==0
                        responseString = char(tResponse(strfind (char(tResponse), 'ch out of range'):end));
                        fprintf(1, '%s. \n', responseString)
                    end
                end

                if(length(tResponse) == 0)
                    AllDataDeOxy = tGetAllDataDeOxy(obj, ch, frame);
                    return;
                end
                % int ROI
                ch = double(swapbytes(typecast(tResponse(1:4),'int32'))) + 1; % zero index-based
                tResponse(1:4) = [];

                % int toTimePoint
                 frame = double(swapbytes(typecast(tResponse(1:4),'int32'))); % zero index-based
                tResponse(1:4) = [];


                % float DataOxy

                tResp_swap = swapbytes(tResponse);
                data = double(swapbytes(typecast(tResp_swap, 'single')));
                if AllDataDeOxy == 0
                    AllDataDeOxy = data;
                else
                    AllDataDeOxy = [AllDataDeOxy;data];
                end
            end
        end     
        function FullNrOfPredictors = tGetFullNrOfPredictors(obj)
            %   Send: tGetNrOfChannels
            %   Receive: int NrOfChannels
            %   Provides the number of available channels
            
            [rOK, aOK, tResponse]= obj.tsiClient.query('tGetFullNrOfPredictors' );
            
            % dim_x
            FullNrOfPredictors = double(swapbytes(typecast(tResponse(1:4),'int32')));
            tResponse(1:4) = [];
            
        end     
        function NrOfConfoundPredictors = tGetNrOfConfoundPredictors(obj)
            %   Send: tGetNrOfChannels
            %   Receive: int NrOfChannels
            %   Provides the number of available channels
            
            [rOK, aOK, tResponse]= obj.tsiClient.query('tGetNrOfConfoundPredictors' );
            
            % dim_x
            NrOfConfoundPredictors = double(swapbytes(typecast(tResponse(1:4),'int32')));
            tResponse(1:4) = [];
            
        end     
        function ValueOfDesignMatrix = tGetValueOfDesignMatrix(obj, pred, timepoint, oxy)
            %   Send: tGetValueOfDesignMatrix
            %   Receive: float ValueOfDesignMatrix
            %   Provides the value of a pred in DM
             
            % define output variable according to user guide
            output(1) = {pred-1};
            output(2) = {timepoint-1};
            output(3) = {oxy};
            [rOK, aOK, tResponse]= obj.tsiClient.query('tGetValueOfDesignMatrix',output );

            pred = double(swapbytes(typecast(tResponse(1:4),'int32'))) + 1; % zero index-based
            tResponse(1:4) = [];

            timepoint = double(swapbytes(typecast(tResponse(1:4),'int32'))); % zero index-based
            tResponse(1:4) = [];
            
            oxy = double(swapbytes(typecast(tResponse(1:4),'int32'))); % zero index-based
            tResponse(1:4) = [];
            %tResponse(1) = [];
            % dim_x
            
            %tResp_swap = swapbytes(tResponse)
            %ValueOfDesignMatrix = double(swapbytes(typecast(tResponse, 'single')));
            ValueOfDesignMatrix = double(typecast(uint8(tResponse(4:-1:1)), 'single'));
            tResponse(1:4) = [];
%             ValueOfDesignMatrix = typecast(uint8(tResponse(4:-1:1)), 'single');


            
        end     
        function Condition = tGetProtocolCondition(obj, frame)
            %   Send: tGetNrOfChannels
            %   Receive: int NrOfChannels
            %   Provides the number of available channels
            output(1) = {frame};

            [rOK, aOK, tResponse]= obj.tsiClient.query('tGetProtocolCondition', output );

            if numel(tResponse)~=12
                % Find error
                if  ~numel(strfind (char(tResponse), 'frame out of range'))==0
                    responseString = char(tResponse(strfind (char(tResponse), 'ch out of range'):end));
                    fprintf(1, '%s. \n', responseString)
                end
            end

            frame = double(swapbytes(typecast(tResponse(1:4),'int32'))); % zero index-based
            tResponse(1:4) = [];
            Condition = double(swapbytes(typecast(tResponse(1:4),'int32')));
            tResponse(1:4) = [];

        end   
        function SamplingRate = tGetSamplingRate(obj)
            %   Send: tGetRawDataScaleFactor
            %   Receive: int roi
            %   Provides the scale factor set in the GUI to multiply the raw data wavelength values. While not
            %      necessary, It is recommended that accessed data (see below) is multiplied by this value to be
            %      compatible with the values displayed in the GUI. Inspect the provided ExamplePlugin code for more
            %      details.

            % send request and read message/response
            [rOK, aOK, tResponse]= obj.tsiClient.query('tGetSamplingRate');
            
            % float RawDataScaleFactor
            SamplingRate = double(typecast(uint8(tResponse(4:-1:1)), 'single'));
            
            % fprintf(1, '\n - answer received - message: ROI # %i, meanvalue - %i \n\n',nrOfROI, meanOfROI);
            
        end     
        
        function numClasses = tGetNumberOfClasses (obj)
            %       Send: tGetNumberOfClasses
            %       Receive: int n_classes
            %       Provides the number of classes for which values are provided.
            %           In case that the real-time SVM classifier is not used, this
            %           function returns -3; in case that the real-time SVM classifier
            %           dialog is open but the classifier is not producing incremental
            %           output, this function returns -2; if the classifier is
            %           working but no output has been generated yet, this function returns 0.
            %           You only should use the tGetCurrentClassifierOutput() function
            %           (see below) if this function returns a positive value. Based on the
            %           returned (positive) value (assigned to e.g. variable n_classes),
            %           the size of the array needed for the tGetCurrentClassifierOutput()
            %           function can be calculated as the number of pair comparisons n_pairs:
            %   n_pairs = n_classes * (n_classes - 1) / 2
            
            [rOK, aOK, tResponse]= obj.tsiClient.query('tGetNumberOfClasses');
            
            
            numClasses = double(swapbytes(typecast(tResponse(1:4),'int32')));
            tResponse(1:4) = [];
            
            
        end
        
        function winner = tGetCurrentClassifierOutput (obj)
            %       Send: tGetCurrentClassifierOutput
            %       Receive: int winner
            %       Provides results during real-time SVM classification for the current time point.
            %           The function returns an integral value indicating which class is predicted, i.e. 
            %           which class label has been assigned to the current brain activity pattern. 
            %           Note that the returned value is 1-based, i.e. if the first class is predicted, 
            %           value 1 is returned, if the second class is predicted, value 2 is returned and so on.
            
            [rOK, aOK, tResponse]= obj.tsiClient.query('tGetCurrentClassifierOutput');
            winner = double(typecast(uint8(tResponse(4:-1:1)), 'single'));
            
            
            
        end
        
    end
    
end
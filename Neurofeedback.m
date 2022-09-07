%  A Neurofeedback class with functions to collect and interpret data from TurboSatori and
%  output a TCP connection
%
% Usage:
%   >> See Example.m

classdef Neurofeedback
    methods (Static)
        function res = Amplitude
            %% Set up connection to Turbo-Satori
            configs.TSI_IP = 'localhost';
            configs.TSI_PORT = 55555;
            
            tsiNetInt = TSINetworkInterface( TSIClient( configs.TSI_IP, configs.TSI_PORT ) );
            
            tsiNetInt.createConnection();
            
            tic
            %% Connect to Unity
            
            tcpipClient = tcpip('127.0.0.1',55001,'NetworkRole','Client');
            set(tcpipClient,'Timeout',30);
            
            %% Get TS data and send to Unity
            while(1)
                % Get current time
                timePoint = tsiNetInt.tGetCurrentTimePoint();
            
                % Get selected channels
                NrOfSelectedChannels = tsiNetInt.tGetNrOfSelectedChannels();
                SelectedChannels = tsiNetInt.tGetSelectedChannels();
            
                % Get Oxy info
                DataOxy = tsiNetInt.tGetDataOxy(SelectedChannels, timePoint);
                AllDataOxy = tsiNetInt.tGetAllDataOxy(SelectedChannels, timePoint);
                
                % Send to unity
                fopen(tcpipClient);
                
                % Basic version of data stream
                DataStream = sprintf('%.7f', mean(DataOxy)); % Averages the selected channels
                fwrite(tcpipClient, DataStream);
                fclose(tcpipClient);
                pause(.09);
            end
        end
        
        function res = Derivative
            %% Set up connection to Turbo-Satori
            configs.TSI_IP = 'localhost';
            configs.TSI_PORT = 55555;
            
            tsiNetInt = TSINetworkInterface( TSIClient( configs.TSI_IP, configs.TSI_PORT ) );
            
            tsiNetInt.createConnection();
            
            tic
            %% Connect to Unity
            tcpipClient = tcpip('127.0.0.1',55001,'NetworkRole','Client');
            set(tcpipClient,'Timeout',30);
            
            %% Derivative
            while(1)
                x_vals = zeros(1,2);
                y_vals = zeros(1,2);
                for c = 1:2
                    % Get current time
                    timePoint = tsiNetInt.tGetCurrentTimePoint();

                    % Get selected channels
                    NrOfSelectedChannels = tsiNetInt.tGetNrOfSelectedChannels();
                    SelectedChannels = tsiNetInt.tGetSelectedChannels();

                    % Get Oxy info
                    DataOxy = tsiNetInt.tGetDataOxy(SelectedChannels, timePoint);
                    AllDataOxy = tsiNetInt.tGetAllDataOxy(SelectedChannels, timePoint);

                    % Derivative
                    x_vals(c) = [timePoint];
                    y_vals(c) = [mean(DataOxy)];
                    pause(.05);
                end
                dydx = diff(y_vals(:))./diff(x_vals(:));
                % Send to unity
                fopen(tcpipClient);
    
                % Basic version of data stream
                DataStream = sprintf('%.7f', dydx * 10); % Averages the selected channels
                fwrite(tcpipClient, DataStream);
                fclose(tcpipClient);
            end
        end
        
        % The following two functions each store the currently selected
        % channels within TurboSatori, allowing comparisons between channel
        % groups
        function res = SelectChannels1
            configs.TSI_IP = 'localhost';
            configs.TSI_PORT = 55555;
            tsiNetInt = TSINetworkInterface( TSIClient( configs.TSI_IP, configs.TSI_PORT ) );
            tsiNetInt.createConnection();
            tic
            
            global ChanGroup1;
            ChanGroup1 = tsiNetInt.tGetSelectedChannels();
        end
        
        function res = SelectChannels2
            configs.TSI_IP = 'localhost';
            configs.TSI_PORT = 55555; 
            tsiNetInt = TSINetworkInterface( TSIClient( configs.TSI_IP, configs.TSI_PORT ) );
            tsiNetInt.createConnection();
            tic
            global ChanGroup2;
            ChanGroup2 = tsiNetInt.tGetSelectedChannels();
        end
        
        
        % Compute correlation between average values of two groups
        function res = Correlation
            global ChanGroup2;
            global ChanGroup1;
            %% Set up connection to Turbo-Satori
            configs.TSI_IP = 'localhost';
            configs.TSI_PORT = 55555;
            
            tsiNetInt = TSINetworkInterface( TSIClient( configs.TSI_IP, configs.TSI_PORT ) );
            
            tsiNetInt.createConnection();
            
            tic
            %% Connect to Unity
            
            tcpipClient = tcpip('127.0.0.1',55001,'NetworkRole','Client');
            set(tcpipClient,'Timeout',30);
            
            %% Correlation
            DataOxy1 = zeros(1,50);
            DataOxy2 = zeros(1,50);
    
            for c = 1:50
                % Get current time
                timePoint = tsiNetInt.tGetCurrentTimePoint();

                % Get oxy data per group
                DataOxy1(c) = mean(tsiNetInt.tGetDataOxy(ChanGroup1, timePoint));
                DataOxy2(c) = mean(tsiNetInt.tGetDataOxy(ChanGroup2, timePoint));
                pause(.4);
            end
            while(1)
                timePoint = tsiNetInt.tGetCurrentTimePoint();

                NewOxy1 = mean(tsiNetInt.tGetDataOxy(ChanGroup1, timePoint));
                NewOxy2 = mean(tsiNetInt.tGetDataOxy(ChanGroup2, timePoint));

                DataOxy1(2:50) = DataOxy1(1:49);
                DataOxy2(2:50) = DataOxy2(1:49);

                DataOxy1(1) = NewOxy1;
                DataOxy2(1) = NewOxy2;
                Coeff = corrcoef(DataOxy1, DataOxy2);
                a = Coeff(2);

                 % Send to unity
                fopen(tcpipClient);

                % Basic version of data stream
                DataStream = sprintf('%.7f', a * .001); % Averages the selected channels
                fwrite(tcpipClient, DataStream);
                fclose(tcpipClient);
                pause(.05)
            end
        end
        
        
        % Compute correlation between average values of two groups
        function res = AntiCorrelation
            global ChanGroup2;
            global ChanGroup1;
            %% Set up connection to Turbo-Satori
            configs.TSI_IP = 'localhost';
            configs.TSI_PORT = 55555;
            
            tsiNetInt = TSINetworkInterface( TSIClient( configs.TSI_IP, configs.TSI_PORT ) );
            
            tsiNetInt.createConnection();
            
            tic
            %% Connect to Unity
            
            tcpipClient = tcpip('127.0.0.1',55001,'NetworkRole','Client');
            set(tcpipClient,'Timeout',30);
            
            %% Anti-Correlation  
            DataOxy1 = zeros(1,50);
            DataOxy2 = zeros(1,50);

            for c = 1:50
                % Get current time
                timePoint = tsiNetInt.tGetCurrentTimePoint();

                % Get oxy data per group
                DataOxy1(c) = mean(tsiNetInt.tGetDataOxy(ChanGroup1, timePoint));
                DataOxy2(c) = mean(tsiNetInt.tGetDataOxy(ChanGroup2, timePoint));
                pause(.4);
            end

            
            while (1)
                timePoint = tsiNetInt.tGetCurrentTimePoint();

                NewOxy1 = mean(tsiNetInt.tGetDataOxy(ChanGroup1, timePoint));
                NewOxy2 = mean(tsiNetInt.tGetDataOxy(ChanGroup2, timePoint));

                DataOxy1(2:50) = DataOxy1(1:49);
                DataOxy2(2:50) = DataOxy2(1:49);

                DataOxy1(1) = NewOxy1;
                DataOxy2(1) = NewOxy2;
                Coeff = corrcoef(DataOxy1, DataOxy2);
                a = Coeff(2);

                 % Send to unity
                fopen(tcpipClient);

                % Basic version of data stream
                DataStream = sprintf('%.7f', a * -.001); % Averages the selected channels
                fwrite(tcpipClient, DataStream);
                fclose(tcpipClient);
                pause(.05)
            end
        end
    end
end
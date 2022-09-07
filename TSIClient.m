% tsiNetworkInterface - Interface class between client and TSI server
%
% Usage:
%   >> obj = tsiNetworkInterface (OutputStream, InputStream)
%
% properties:
%
%
% Author(s): Bruno Direito, Jo?o Lima, Marco Sim?es, IBILI, 12 May 2014

classdef TSIClient < handle
    
    properties (SetAccess = private)
        host
        port
        
        rSocket
        rInputReqStream
        rOutputReqStream
        
        eSocket
        eInputReqStream
        eOutputReqStream
        
        inChann
        buffer
        
        array
        
        
    end
    
    
    methods
        
        function obj = TSIClient(host, port)  % constructor
            [folder, name, ext]  = fileparts(which('TSIClient'));
            javaaddpath([folder,'\utils']);
            obj.host = host;
            obj.port = port;
            
        end
        
        
        function createConnection(obj)
            
            import java.net.Socket
            import java.io.*
            import java.nio.*

            %--------------------------
            % OPEN Request Socket
            %--------------------------
            obj.rSocket = Socket(obj.host, obj.port);
            %timeout after 1 second
            obj.rSocket.setSoTimeout(2000);
            
            % input and output stream from the socket
            obj.rOutputReqStream = DataOutputStream( obj.rSocket.getOutputStream);
            obj.rInputReqStream = DataInputStream( obj.rSocket.getInputStream);
            
            obj.inChann = java.nio.channels.Channels.newChannel(obj.rInputReqStream);
            

            %obj.inChann.ConfigureBlocking(false);
            
            BUFFER_SIZE = 1024*1024*20; % 20MB
            
            % create buffer to put read data into
            obj.array	= zeros(1,BUFFER_SIZE,'int8');
            
            obj.buffer	= java.nio.ByteBuffer.wrap(obj.array);
            
            
            
            
            %[~, message] =  get_message (obj.rInputReqStream);
            
            % SEND Request --- Connect to Request Socket
            rOK = obj.sendRequest('Request Socket');
            [rOK, message] =  obj.getMessage();
            
%             fprintf(1, ' --- request socket open: %i\n\n', rOK);
            
            %             %--------------------------
            %             % OPEN Execute Socket
            %             %--------------------------
            %             obj.eSocket = Socket(obj.host, obj.port);
            %
            %             obj.eOutputReqStream = DataOutputStream(obj.eSocket.getOutputStream);
            %
            %             obj.eInputReqStream = DataInputStream(obj.eSocket.getInputStream);
            %
            %             pause(.5);
            %
            %             % SEND Request --- Connect to Request Socket
            %             eOK = send_request (obj.eOutputReqStream, 'Execute Socket');
            %             %[eOK, message] =  get_message (obj.eOutputReqStream);
            %
            %             fprintf(1, ' --- execute socket open: %i\n\n', eOK);
            %
            
            % NFLogger.getLogger().log('TSI Connection opened (Request Socket)');
        end
        
        
        function closeConnection(obj)
            obj.rSocket.close;
%             NFLogger.getLogger().log('TSI Connection closed');
            %obj.eSocket.close;
        end
        
        
        function [rOK, aOK, message] = query (obj, request, outputs)
            import java.net.Socket
            import java.io.*
            
            aOK = 0;
            
            
            if nargin<3
                outputs = [];
            end
            
            
%             NFLogger.getLogger().log(['TSI query: ' request]);
            
            try
                % Send request
                rOK = obj.sendRequest(request, outputs);
            catch error
                error
                rOK = 0;
                aOK = 0;
                message = [];
            end
            
            
            try
                % if request rOK - Wait for answer from server
                if rOK
                    
                    [aOK, message] =  obj.getMessage();
                else
%                     fprintf(1, ' --- request %s WAS NOT sent.\n', request);
                end
            catch error
                error
                rOK = 1;
                aOK = 0;
                message = [];
            end
            
            
        end
        
        
        function [rOK, aOK, message] = queryVolumeData (obj, request, outputs)
            import java.net.Socket
            import java.io.*
            
            aOK = 0;
            
            
            if nargin<3
                outputs = [];
            end
            
            
%             NFLogger.getLogger().log(['TSI query: ' request]);
            
            try
                % Send request
                rOK = obj.sendRequest(request, outputs);
            catch error
                error
                rOK = 0;
                aOK = 0;
                message = [];
            end
            
            
            try
                % if request rOK - Wait for answer from server
                if rOK
                    
                    [aOK, message] =  obj.getVolumeDataMessage(request);
                else
%                     fprintf(1, ' --- request %s WAS NOT sent.\n', request);
                end
            catch error
                error
                rOK = 1;
                aOK = 0;
                message = [];
            end
            
            
        end
        
        
        function [ok] = sendRequest(obj, request, output)
            import java.net.Socket
            import java.io.*
            
            if nargin < 3
                output = [];
            end
            
            
            
            ok = 1;
            
            try
                % create message with request
                
                % char to byte
                request = uint8(request);
                request(end+1) = 0;
                
                % length of the request (4 bytes)
                requestLength = numToByte( length(request), 4 );
                
                
                % add request parameters
                outputVar = [];
                for i = 1 : numel(output)
                    outputVar = [outputVar numToByte(output{i}, 4)];
                end
                
                
                %length of the message
                messageSize = numToByte( ...
                    length(request) ...
                    + length(requestLength) ...
                    + length(outputVar) ...
                    , 8);
                
                % complete message to send @ TSIserver
                toSend = [messageSize requestLength request outputVar];
                
                % Send Message using dataOutputStream
                obj.rOutputReqStream.write(toSend, 0, length(toSend));
                obj.rOutputReqStream.flush();
                
%                 NFLogger.getLogger().log(['TSI Request sent: ' toSend]);
            catch err
                err
                ok = 0;
            end
            
        end
        
        
        function [requestOk, response] = getMessage(obj)
            
            import java.net.Socket
            import java.io.*
            
            HEADER_MSG_SIZE = 8;
            
            requestOk = 1;
            response = [];
            
            counter = 0;
            
            msgSize = [];
%             message = uint8([]);
            message = [];
            
            
%               pause(.001);
            
            try
                
                
                % read message size
                while 1
                    
                    bytesAvailable = obj.rInputReqStream.available;
                    if bytesAvailable > HEADER_MSG_SIZE
                        break
                    end
                    
                      pause(.00001);
%                     disp('waiting...')
                    
                    % breaks if too much time passed
                    counter = counter + 1;
                    if counter > 2000
                        requestOk = 0;
                        return
                    end
                    
                end
                
                
                for i=1:HEADER_MSG_SIZE
                    msgSize(i) = typecast(int8(obj.rInputReqStream.readByte()), 'uint8');
                end
                
                
                
                msgSize = byteToNum(msgSize);
%                 fprintf(1, '\n - message size - %d\n',msgSize);
                
                data_reader = DataReader(obj.rInputReqStream);
                % read message size
                while 1
                    
                    bytesAvailable = obj.rInputReqStream.available;
                    if bytesAvailable >= msgSize - length(message)
                        break
                    elseif bytesAvailable > 0
                        message = [message;data_reader.readBuffer(bytesAvailable)];  
                    end
                    
                    pause(.0001);
%                     disp('waiting...')
                    
                    % breaks if too much time passed
                    counter = counter + 1;
                    if counter > 50
                        requestOk = 0;
                        return
                    end
                    
                end
                
                
                message = [message;data_reader.readBuffer(msgSize - length(message))];
               
              
                message = rot90(typecast(int8(message), 'uint8'));
                
%                 for i=1:msgSize
%                     message(i) = typecast(int8(obj.rInputReqStream.readByte()), 'uint8');
%                 end
                
%                 fprintf(1, '\n - message received - %s\n',message);
                
                % the response is returned as uint8
                [requestSize, request, response] = obj.decodeMessage(message);
                
%                 NFLogger.getLogger().log(['TSI Response received: ' response]);
                
            catch error
                error.message
                requestOk = 0;
                
            end
            
        end
        
        
        function [requestOk, response] = getVolumeDataMessage(obj, request)
            
            import java.net.Socket
            import java.io.*
            
            HEADER_MSG_SIZE = 8;
            
            requestOk = 1;
            response = [];
            
            counter = 0;
            
            msgSize = [];
            message = uint8([]);
            
            
            
            pause(.01);
            
            try
                
                
                % read message size
                while 1
                    
                    bytesAvailable = obj.rInputReqStream.available;
                    if bytesAvailable > HEADER_MSG_SIZE
                        break
                    end
                    
                    pause(.1);
%                     disp('waiting...')
                    
                    % breaks if too much time passed
                    counter = counter + 1;
                    if counter > 5
                        requestOk = 0;
                        return
                    end
                    
                end
                
                
                for i=1:HEADER_MSG_SIZE
                    msgSize(i) = typecast(int8(obj.rInputReqStream.readByte()), 'uint8');
                end
                
                %fprintf(1, '\n - message size - %s\n',msgSize);
                msgSize = byteToNum(msgSize);
%                 fprintf(1, '\n - message size - %d\n',msgSize);
                
                
                %                 % read message size
                %                 while 1
                %
                %                     bytesAvailable = obj.rInputReqStream.available;
                %                     if bytesAvailable >= msgSize
                %                         break
                %                     end
                %
                %                     pause(.1);
                %                     disp('waiting...')
                %
                %                     % breaks if too much time passed
                %                     counter = counter + 1;
                %                     if counter > 5
                %                         requestOk = 0;
                %                         return
                %                     end
                %
                %                 end
                
              
                
                message = [];
                bytesRead = 0;
                
                bytesReadTotal = 0;
                
                while 1
                    
                    bytesRead = obj.inChann.read(obj.buffer);
                    
                    
                    
                    
                    bytesReadTotal = bytesReadTotal + bytesRead;
                    
                    tempMessage = obj.buffer.array;
                    tempMessage = tempMessage ( 1: obj.buffer.position )';
                    
                    message = [message tempMessage];
                    
                    obj.buffer.clear();
                    
                    if bytesRead == 0 || bytesReadTotal >= msgSize
                        break;
                    end
                    
                    
                end
                
                
                %                 for i=1:msgSize
                %                     message(i) = typecast(int8(obj.rInputReqStream.readByte()), 'uint8');
                %                 end
                
                %                 message = obj.buffer.array;
                %                 message(msgSize:end) = [];
                %
                
                % the response is returned as uint8
                [requestSize, request, response] = obj.decodeMessage(message);
                
                % NFLogger.getLogger().log(['TSI Response received: ' response]);
                
            catch error
                error.message
                requestOk = 0;
                
            end
            
        end
        
        
        function [requestSize, request, response] = decodeMessage(obj, message)
            
            requestSize = byteToNum( message(1:4) );
            message(1:4) = [];
            
            request = char( message(1:requestSize) );
            message(1:requestSize) = [];
            
            response = message;
            
        end
        
        
        
        
    end
    
end



function [ result ] = byteToNum( bytes )
%BYTETONUM TODO
    result = 0;
    for i=0:length(bytes)-1
        result = result + double(bytes(end-i)* 256^i) ;
    end
end

function [ result ] = numToByte( number, nBytes )
%NUMTOBYTE TODO

    result = zeros(1, nBytes);
    for i=0:nBytes-1
        result(end-i) = mod(number, 256);
        number = floor( number / 256 );
    end

end




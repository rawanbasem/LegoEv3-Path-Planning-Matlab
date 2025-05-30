videoFrame = snapshot(cam);
videoFrame = imrotate(videoFrame,270);

% Track the points. Note that some points may be lost.
[points, isFound] = step(pointTracker, videoFrame);
visiblePoints = points(isFound, :);
oldInliers = oldPoints(isFound, :);
a = 640;
if size(visiblePoints, 1) >= 2 % need at least 2 points
        
    % Estimate the geometric transformation between the old points
    % and the new points and eliminate outliers
    [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
        oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
        
    % Apply the transformation to the bounding box points
    bboxPoints = transformPointsForward(xform, bboxPoints);
        
    % Reset the points
    oldPoints = visiblePoints;
    setPoints(pointTracker, oldPoints); 
        
    % Put coordinate arrows!
    videoFrame = insertShape(videoFrame,'line',[5 a-5 30 a-5; 30 a-5 25 a-9; 30 a-5 25 a-1],'LineWidth',2,'Color','black');
    videoFrame = insertShape(videoFrame,'line',[5 a-5 5 a-30; 5 a-30 1 a-25; 5 a-30 9 a-25],'LineWidth',2,'Color','red');
    videoFrame = insertText(videoFrame,[28 a-25],'x','FontSize',18,'BoxColor','black','BoxOpacity',0,'TextColor','black');
    videoFrame = insertText(videoFrame,[-1 a-60],'y','FontSize',18,'BoxColor','black','BoxOpacity',0,'TextColor','red'); 
    
    % Front point of the robot!
    x1 = (bboxPoints(1,1)+bboxPoints(2,1))/2;
    y1 = (bboxPoints(1,2)+bboxPoints(2,2))/2;
    % Rear point of the robot!
    x2 = (bboxPoints(3,1)+bboxPoints(4,1))/2;
    y2 = (bboxPoints(3,2)+bboxPoints(4,2))/2;
    m = -atan2(y1-y2, x1-x2); % Angle of the robot!
    
    % Robot trajectory
    if isempty(traj)
        traj = [x1 y1 x1 y1];
    else
        prev = traj(end,3:4);
        traj = [traj; prev x1 y1];
    end
    videoFrame = insertShape(videoFrame,'line',traj,'LineWidth',2,'Color','cyan');
    
    % Robot annotations!
    % Insert a bounding box around the object being tracked
    bboxPolygon = reshape(bboxPoints', 1, []);
    videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 2,'Color','yellow');                
    % Display tracked points
    videoFrame = insertMarker(videoFrame, visiblePoints, '+','Color', 'white');
    text_str = [num2str(round(calib*x1)) ', ' num2str(round(calib*(a-y1))) ', ' num2str(round(m*180/pi))];        
    videoFrame = insertText(videoFrame,[x1,y1],text_str,'FontSize',18,'BoxColor','yellow','BoxOpacity',1,'TextColor','black');
    videoFrame = insertShape(videoFrame,'circle',[x1 y1 10],'LineWidth',5,'Color','yellow'); 
    videoFrame = insertShape(videoFrame,'circle',[x1 y1 4],'LineWidth',3,'Color','yellow'); 
    videoFrame = insertShape(videoFrame,'circle',[x2 y2 5],'LineWidth',5,'Color','yellow');
     
    
    % Goal annotations!
    text_str = [num2str(round(calib*xg)) ', ' num2str(round(calib*(a-yg)))];        
    videoFrame = insertText(videoFrame,[xg yg],text_str,'FontSize',18,'BoxColor','green','BoxOpacity',0.8,'TextColor','black');
    videoFrame = insertShape(videoFrame,'circle',[xg yg 10],'LineWidth',5,'Color','green');
    videoFrame = insertShape(videoFrame,'circle',[xg yg 4],'LineWidth',3,'Color','green');      

    % Obstacles' annotations!
    num=size(obstacle_points,1);
    obstacle_pixels = obstacle_points;
    for j=1:1:num
        xo = obstacle_pixels(j,1);
        yo = obstacle_pixels(j,2);
        text_str = [num2str(round(calib*xo)) ', ' num2str(round(calib*(a-yo)))];
        videoFrame = insertText(videoFrame,[xo yo],text_str,'FontSize',18,'BoxColor','red','BoxOpacity',0.8,'TextColor','white');
        videoFrame = insertShape(videoFrame,'circle',[xo yo 10],'LineWidth',5,'Color','red');
        videoFrame = insertShape(videoFrame,'circle',[xo yo 4],'LineWidth',3,'Color','red');
        
    end        

    robot = [calib*x1 calib*(a-y1) round(m*180/pi)];
    goal = [calib*xg  calib*(a-yg)];
    obstacles = [calib*obstacle_pixels(:,1) calib*((a*ones(num,1))-(obstacle_pixels(:,2)))];
     

end
    
    % Display the annotated video frame using the video player object
    step(videoPlayer, videoFrame);
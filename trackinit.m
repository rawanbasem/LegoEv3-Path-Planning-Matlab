mylego = legoev3('usb');
beep(mylego)
mB = motor(mylego,'B');
mC = motor(mylego,'C');
mB.Speed=0;
mC.Speed=0;
start(mB);
start(mC);
cam = webcam(1);
while ~readButton(mylego, 'down')
    im = snapshot(cam);
    im = imrotate(im,270);
    str = 'Press down button if you are ready!';
    im = insertText(im,[10 10],str,'FontSize',18,'BoxColor','black','BoxOpacity',0.5,'TextColor','green');
    imshow(im)
end
i=0;
countdown = 3;
while (i<countdown)
    im = snapshot(cam);
    im = imrotate(im,270);
    str = num2str(countdown-i);
    im = insertText(im,[10 10],str,'FontSize',18,'BoxColor','black','BoxOpacity',0.5,'TextColor','green');
    imshow(im)
    pause(0.5)
    i=i+1;
end
im = snapshot(cam);
im = imrotate(im,270);
im2 = im;
str= 'Select the robot with rectangle!';
im = insertText(im,[10 10],str,'FontSize',18,'BoxColor','black','BoxOpacity',0.5,'TextColor','green');
imshow(im)
bbox = getrect;
videoFrame = insertShape(im2, 'Rectangle', bbox);
imshow(videoFrame);
bboxPoints = bbox2points(bbox(1, :));
points = detectMinEigenFeatures(rgb2gray(im2), 'ROI', bbox);
imshow(videoFrame), hold on;
str= 'Click on the target point and enter!';
im3 = insertText(videoFrame,[10 10],str,'FontSize',18,'BoxColor','black','BoxOpacity',0.5,'TextColor','green');
imshow(im3)
plot(points);
[xg, yg] = getpts;
xg=xg(end);
yg=yg(end);
str= 'Click on the obstacle points and enter!';
im3 = insertText(videoFrame,[10 10],str,'FontSize',18,'BoxColor','black','BoxOpacity',0.5,'TextColor','green');
imshow(im3)
plot(points);
[xo, yo] = getpts;
obstacle_points=[xo yo];
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
points = points.Location;
initialize(pointTracker, points, videoFrame);
videoPlayer  = vision.VideoPlayer('Position',[100 100 [size(videoFrame, 2), size(videoFrame, 1)]+30]);
oldPoints = points;
traj=[];
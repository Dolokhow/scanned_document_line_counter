function lproc(filepath)
	%pkg load image;
	%filepath = input("","s");
	t=cputime;
	im = imread(filepath);
	SIZE = 704;
	num = 0;
	temp_num = num;
	test_num_c = 0;
	test_num_cc = 0;
	cropped = false;
	approx_angle = 0;
	
	imInfo = imfinfo(filepath);
	width = imInfo.Width;
	height = imInfo.Height;
	ImSize = imInfo.FileSize;
	
	if(ImSize > 1182886)
		im = im(1:height, 1:width/4);
		im = imresize(im, [SIZE SIZE]);
		cropped = true;
	else
		im = imresize(im, [SIZE SIZE]); 
	endif
	
	im = im(1:SIZE, 1:SIZE);
	
	
	if (mean2(im) < 200)
		for i = 1: SIZE/16
			
			if(i == 1)
				m = mean2(im(1:16,1:SIZE));
				im_1 = im(1:16,1:SIZE) < m;
				out = im_1;
			else
				m = mean2(im((i-1)*16:(i-1)*16+16,1:SIZE));
				im_1 = im((i -1)*16:(i-1)*16+16,1:SIZE) < m;
				out = [out;im_1];
			endif
		endfor
		im = out;
		clear im_1;
		clear out;
	else
		im = ~im2bw(im);
	endif
	
	
	se = strel('line', size(im,2), 0);
	out = imdilate(im, se);
	[~,num] = bwlabel(out);
	or_variance = var(out(:));
	printf('Original variance is: %f\n', or_variance); 
	
	rotated = false;
	clockwise = false;
	holdup = true;
	
	
	for i = 1:6,
		se = strel('line', size(im,2), -5*i);
		out = imdilate(im, se);
		clear se;
		var_c = var(out(:));
		
		if(var_c > or_variance)
			or_variance = var_c;
			clockwise = true;
			rotated = true;
			
			approx_angle = -5*i;
			printf('New angle estimate is: %d\n', approx_angle); 
		endif
	endfor
	
	if (clockwise == false) 
		for i = 1:6,
			se = strel('line', size(im,2), 5*i);
			out = imdilate(im, se);
			clear se;
			var_cc = var(out(:));
			printf('New variance is: %f\n', var_cc);
			
			
			if(var_cc > or_variance)
				or_variance = var_cc;
				rotated = true;
				 
				approx_angle = 5*i;
				printf('New angle estimate is: %d\n', approx_angle); 
			endif
		endfor
	endif
	
	
	
	
	angle = approx_angle;
	printf('Estimated angle is: %d\n', approx_angle);
	if (rotated == true)
	
		if(cropped == false) 
			im = im(1:SIZE, 1:SIZE/4);
		endif
	
		for i = 1:30
			
			se = strel('line', size(im,2), approx_angle-0.25*i);
			out = imdilate(im, se);
			[~,test_num_c] = bwlabel(out);
			if (test_num_c > num + 1 && i!= 30)
				num = test_num_c;	
				printf('New estimate is: %d\n at an angle of: %d', num, approx_angle-0.25*i);
			elseif(test_num_c > num && i == 30)
				num = test_num_c;
				printf('New estimate is: %d\n at an angle of: %d', num, approx_angle-0.25*i);
			endif
		
			se = strel('line', size(im,2), approx_angle+0.25*i);
			out = imdilate(im, se);
			[~,test_num_cc] = bwlabel(out);
			if (test_num_cc > num + 1 && i!=30)
				num = test_num_cc;	
				printf('New estimate is: %d\n at an angle of: %d', num, approx_angle+0.25*i);
			elseif(test_num_cc > num && i == 30)
				printf('New estimate is: %d\n at an angle of: %d', num, approx_angle+0.25*i);
				num = test_num_cc;
			endif
		endfor
	endif
	
	clear im;
	clear out;
	clear se;
	
	fprintf('%d\n', num);
	printf('Total cpu time: %f seconds\n', cputime-t);
endfunction
	
	

local Draw = {}

function Draw.drawmax(drawable, maxwidth, maxheight, ratio, x, y, rotation, ...)
	local ratio = ratio or 1;
	local rotation = rotation or 0;
	local x = x or 0;
	local y = y or 0;
	local width = drawable:getWidth() / ratio;
	local height = drawable:getHeight() * ratio;
	local scale_ratio = width / height;
	local new_width = math.min(width, maxwidth);
	local new_height = math.min(height, maxheight);
	local new_scale_ratio = new_width / new_height;

	local draw_width, draw_height = new_width, new_height;

	-- now taller
	if new_scale_ratio < scale_ratio then
		draw_height = new_height;
		draw_width = draw_height * scale_ratio;
	-- now wider
	elseif new_scale_ratio > scale_ratio then
		draw_width = new_width;
		draw_height = draw_width / scale_ratio
	end

	local sx = draw_width / drawable:getWidth();
	local sy = draw_height / drawable:getHeight();
	love.graphics.draw(drawable, x, y, rotation, sx, sy, ...);
end

return Draw;

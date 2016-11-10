local Matrix3 = {}
Matrix3.__index = Matrix3;
function Matrix3:__tostring()
	return
	([=[[%.2f, %.2f, %.2f,
 %.2f, %.2f, %.2f,
 %.2f, %.2f, %.2f]]=]):format(unpack(self))
end

local default_mat = {1,0,0, 0,1,0, 0,0,1}
function Matrix3.new(...)
	local ret = {...}
	for i = #ret+1, #default_mat do
		ret[i] = default_mat[i]
	end
	return setmetatable(ret, Matrix3);
end

function Matrix3:clone()
	return Matrix3(unpack(self))
end

function Matrix3:copy(other)
	for i = 1,9 do
		self[i] = other[i]
	end
end

function Matrix3:identity()
	for i = 1,9 do
		self[i] = default_mat[i]
	end
	return self
end

function Matrix3:inverse()
	local a,b,c,d,e,f,g,h,i = unpack(self)

	local det = a*e*i + b*f*g + c*d*h - c*e*g - b*d*i - a*f*g;

	self[1] =  (e*i - f*h)
	self[2] = -(b*i - c*h)
	self[3] =  (b*f - c*e)
	self[4] = -(d*i - f*g)
	self[5] =  (a*i - c*g)
	self[6] = -(a*f - c*d)
	self[7] =  (d*h - e*g)
	self[8] = -(a*h - b*g)
	self[9] =  (a*e - b*d)

	for i = 1,9 do
		self[i] = self[i] / det
	end

	return self
end

function Matrix3:transform_point(x, y, w)
	local w = w or 1
	return
		self[1]*x + self[2]*y + self[3]*w,
		self[4]*x + self[5]*y + self[6]*w,
		self[7]*x + self[8]*y + self[9]*w;
end

function Matrix3:translate(x, y)
	if x == 0 and y == 0 then return self end
	return self:mul(1,0,x, 0,1,y, 0,0,1);
end

function Matrix3:scale(sx, sy)
	if sx == 1 and sy == 1 then return self end
	return self:mul(sx,0,0, 0,sy,0, 0,0,1);
end

function Matrix3:rotate(rot)
	if rot == 0 then return self end
	return self:mul(
		 math.cos(rot), -math.sin(rot), 0,
		 math.sin(rot),  math.cos(rot), 0,
		0, 0, 1)
end

function Matrix3:mul(o1,o2,o3, o4,o5,o6, o7,o8,o9)
	if not o2 and o1 then
		return self:mul(unpack(o1));
	end

	-- I'm almost certain this works
	local s1 = self[1]
	local s2 = self[2]
	local s3 = self[3]
	local s4 = self[4]
	local s5 = self[5]
	local s6 = self[6]
	local s7 = self[7]
	local s8 = self[8]
	local s9 = self[9]
	self[1],self[2],self[3],self[4],self[5],self[6],self[7],self[8],self[9] =
		s1*o1+s2*o4+s3*o7, s1*o2+s2*o5+s3*o8, s1*o3+s2*o6+s3*o9,
		s4*o1+s5*o4+s6*o7, s4*o2+s5*o5+s6*o8, s4*o3+s5*o6+s6*o9,
		s7*o1+s8*o4+s9*o7, s7*o2+s8*o5+s9*o8, s7*o3+s8*o6+s9*o9;
	return self
end

Matrix3.__mul = Matrix3.mul

return setmetatable(Matrix3, {
	__call = function(t, ...)
		return Matrix3.new(...)
	end
})

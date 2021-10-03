shader_type canvas_item;

uniform mat4 global_transform;

uniform float speed1 = -2;
uniform float speed2 = -4;
uniform float amp1 = 10.0;
uniform float amp2 = 3.0;
uniform int period1 = 1; // Must be integer in order to be periodic, see below
uniform int period2 = 4;
const float factor = 0.0122718; //2pi/(16 * 8 * 4), makes it periodic in block size
                                //(tilemap xy values reset every 16 tiles)

void vertex(){
	// Note: to not look bad, period must be 16 or a divisor thereof
	float fac1 = amp1*cos(speed1*TIME + float(period1)*VERTEX.x*factor);
	float fac2 = amp2*cos(speed2*TIME + float(period2)*VERTEX.x*factor);
	VERTEX.y += fac1 + fac2;
}
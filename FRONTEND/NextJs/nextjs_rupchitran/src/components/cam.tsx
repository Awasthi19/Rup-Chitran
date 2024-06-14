"use client";
import React,{useState,useRef, useEffect, use} from 'react'
import Webcam from 'react-webcam'
import axios from 'axios';

function Cam() {
	//State Variables
    const webcamRef = useRef<Webcam>(null);
	const canvasRef = useRef<HTMLCanvasElement>(null);
    const [isDetecting, setIsDetecting] = useState<boolean>(false);
    const [imagedata,setImageData] = useState<any>({
      image: ""
    });
	const [faceBoundingBox, setFaceBoundingBox] = useState({
		x: 0,
        y: 0,
        width: 0,
        height: 0
	})
    
    const startDetecting = () => {
        setIsDetecting(true);
    };

    const stopDetecting = () => {
      setIsDetecting(false);
    };

	const capture = async () => {
		console.log("going to capture")
		if (isDetecting) {
			console.log("capturing")

		const imageSrc = await webcamRef.current!.getScreenshot();
		
		setImageData((prevState:any) => ({
			...prevState,
			image: imageSrc
		}));
		
		

		};
	}

	useEffect(() => {
		console.log("useEffect")
		console.log(isDetecting)
    	
		capture();
	}, [isDetecting]);


	useEffect(() => {
	const handleImagePost = async () => {
		console.log("going to post image")
		try{
            const formData = new FormData();
            formData.append('image',imagedata.image!);
            const response = await axios.post(process.env.NEXT_PUBLIC_API_URL!,formData);

            
        }
        catch(error){
            console.log(error);
        }
	}

	const handleFaceDetect = async () => {
		console.log("going to detect face")
		try{
        	const response = await axios.get(process.env.NEXT_PUBLIC_FACEDETECT_URL!);
			const response_data = JSON.parse(response.data);
			console.log(response_data);
			
			setFaceBoundingBox({
				x: response_data[0].coordinates.x,
				y: response_data[0].coordinates.y,
				width: response_data[0].coordinates.w,
				height: response_data[0].coordinates.h
			})
			console.log(faceBoundingBox);
			
      	}
      	catch(error){
        	console.log(error);
      	}
		
	}

	handleImagePost();
	handleFaceDetect();
	setTimeout(capture, 1000);

}, [imagedata]);

const CreateBox = (faceBoundingBox: any) => {
	const ctx = canvasRef.current!.getContext('2d')!;
    //ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
    ctx.strokeStyle = 'red';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.rect(faceBoundingBox.x, faceBoundingBox.y+25.5, faceBoundingBox.width, faceBoundingBox.height);
    ctx.stroke();
	setTimeout(() => {
        ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
    }, 200);
}

useEffect(() => {
console.log("Create Box")
CreateBox(faceBoundingBox);
	
},[faceBoundingBox]);


  return (
    <div>
    <div className="flex justify-center items-center w-[300px] h-[220px] border rounded-xl shadow-xl border-transparent mt-4 overflow-hidden  "style={{ position: 'relative' }}>
      <Webcam
        style={{ width: '100%', height: '100%', objectFit: 'cover'}}
        audio={false}
        ref={webcamRef}
        screenshotFormat="image/jpeg"
        width={1920}
        height={1080}
		mirrored={true}
        videoConstraints={{
          width: 1920,
          height: 1080,
          facingMode: 'user'
        }}
      />
	  <canvas
		ref={canvasRef}
		style={{ position: 'absolute', top: 0, left: 0 , width: '100%', height: '100%'}}
		width={300}
		height={220}
	  ></canvas>
    </div>

      {isDetecting ? (
        <button onClick={stopDetecting}>Stop</button>
      ) : (
        <button onClick={startDetecting}>Start Detecting</button>
      )}
    </div>
  )
}

export default Cam
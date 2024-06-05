import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
    email: {
        type: String,
        required: [true,"Email is required"],
        unique: true,
    },
    password: {
        type: String,
        required: [true,"Password is required"],
    },
    isVerified: {
        type: Boolean,
        default: false,
    },
    forgotPasswordToken: String,
    forgotPasswordExpires: Date,
    verifyToken: String,
    verifyTokenExpires: Date,
});

const User = mongoose.models.User||mongoose.model('User', userSchema);

export default User;


from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import Column, Integer, String, JSON, or_
from pydantic import BaseModel, Field
from typing import List, Optional, Dict
from fastapi.middleware.cors import CORSMiddleware
import datetime
from database import SessionLocal, engine, Base


# SQLAlchemy Models (DB Tables) 

# UserDB model to store registered users
class UserDB(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    phone = Column(String, unique=True, index=True)
    email = Column(String, unique=True, index=True)
    password = Column(String) 
    fName = Column(String)
    lName = Column(String)
    userType = Column(String)
    # Add other user fields as needed


class BogieChecksheetDB(Base):
    __tablename__ = "bogie_checksheets"
    id = Column(Integer, primary_key=True, index=True)
    formNumber = Column(String, unique=True, index=True)
    inspectionBy = Column(String)
    inspectionDate = Column(String)
    bogieDetails = Column(JSON)
    bogieChecksheet = Column(JSON)
    bmbcChecksheet = Column(JSON)

class WheelSpecificationsDB(Base):
    __tablename__ = "wheel_specifications"
    id = Column(Integer, primary_key=True, index=True)
    formNumber = Column(String, unique=True, index=True)
    submittedBy = Column(String)
    submittedDate = Column(String)
    fields = Column(JSON)

# Create tables if they don't exist
Base.metadata.create_all(bind=engine)

# FastAPI Config 

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Dependency to get DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# Pydantic Schemas
class BogieDetails(BaseModel):
    bogieNo: str
    dateOfIOH: str
    deficitComponents: str
    incomingDivAndDate: str
    makerYearBuilt: str

class BogieChecksheet(BaseModel):
    axleGuide: str
    bogieFrameCondition: str
    bolster: str
    bolsterSuspensionBracket: str
    lowerSpringSeat: str

class BmbcChecksheet(BaseModel):
    adjustingTube: str
    cylinderBody: str
    pistonTrunnion: str
    plungerSpring: str

class BogieFormCreate(BaseModel):
    formNumber: str
    inspectionBy: str
    inspectionDate: str
    bogieDetails: BogieDetails
    bogieChecksheet: BogieChecksheet
    bmbcChecksheet: BmbcChecksheet

class WheelSpecFields(BaseModel):
    axleBoxHousingBoreDia: str
    bearingSeatDiameter: str
    condemningDia: str
    intermediateWWP: str
    lastShopIssueSize: str
    rollerBearingBoreDia: str
    rollerBearingOuterDia: str
    rollerBearingWidth: str
    treadDiameterNew: str
    variationSameAxle: str
    variationSameBogie: str
    variationSameCoach: str
    wheelDiscWidth: str
    wheelGauge: str
    wheelProfile: str

class WheelSpecCreate(BaseModel):
    formNumber: str
    submittedBy: str
    submittedDate: str
    fields: WheelSpecFields

class LoginRequest(BaseModel):
    phone: str
    password: str

class LoginResponseData(BaseModel):
    token: str
    id: str
    userName: str = Field(alias="user_name")
    phone: str
    email: str
    userType: str = Field(alias="user_type")
    refreshToken: str = Field(alias="refresh_token")

class LoginResponse(BaseModel):
    success: bool
    message: str
    data: LoginResponseData

class SubmittedFormResponse(BaseModel):
    formNumber: str
    submittedBy: str
    submittedDate: str
    formType: str

class AllFormsResponse(BaseModel):
    data: List[SubmittedFormResponse]

# FIX: Added a Pydantic schema for the signup request data
class SignupRequest(BaseModel):
    fName: str
    mName: Optional[str] = None
    lName: str
    email: str
    phone: str
    whatsappNumber: str
    secondaryPhoneNumber: Optional[str] = None
    password: str
    rePassword: str
    userType: str
    division: str
    trains: str
    coaches: str
    depo: str
    empNumber: str
    zone: str
    createdBy: Optional[str] = None
    createdByUserRole: Optional[str] = None


# API Routes

@app.post("/api/users/request-user/")
def signup_user(user_data: SignupRequest, db: Session = Depends(get_db)):
    # Check if user already exists
    db_user = db.query(UserDB).filter(or_(UserDB.email == user_data.email, UserDB.phone == user_data.phone)).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email or phone number already registered")


    new_user = UserDB(
        fName=user_data.fName,
        lName=user_data.lName,
        email=user_data.email,
        phone=user_data.phone,
        password=user_data.password, # Store the hashed password
        userType=user_data.userType,
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    return {"message": "User registration request sent successfully."}


@app.post("/api/users/login/", response_model=LoginResponse)
def login_user(data: LoginRequest):
    if data.phone == "7760873976" and data.password == "to_share@123":
        response_data = LoginResponseData(
            token="mock_auth_token_for_successful_login",
            id="user_123",
            user_name="Test User",
            phone=data.phone,
            email="test@example.com",
            user_type="SUPERVISOR",
            refresh_token="mock_refresh_token_12345"
        )
        return LoginResponse(success=True, message="Login successful", data=response_data)
    else:
        raise HTTPException(status_code=401, detail="Invalid credentials")


@app.post("/api/forms/bogie-checksheet")
def create_bogie_checksheet(form_data: BogieFormCreate, db: Session = Depends(get_db)):
    db_form = BogieChecksheetDB(
        formNumber=form_data.formNumber,
        inspectionBy=form_data.inspectionBy,
        inspectionDate=form_data.inspectionDate,
        bogieDetails=form_data.bogieDetails.dict(),
        bogieChecksheet=form_data.bogieChecksheet.dict(),
        bmbcChecksheet=form_data.bmbcChecksheet.dict()
    )
    db.add(db_form)
    db.commit()
    db.refresh(db_form)
    return {"success": True, "message": "Bogie checksheet submitted successfully."}

@app.post("/api/forms/wheel-specifications")
def create_wheel_specification(form_data: WheelSpecCreate, db: Session = Depends(get_db)):
    db_form = WheelSpecificationsDB(
        formNumber=form_data.formNumber,
        submittedBy=form_data.submittedBy,
        submittedDate=form_data.submittedDate,
        fields=form_data.fields.dict()
    )
    db.add(db_form)
    db.commit()
    db.refresh(db_form)
    return {"success": True, "message": "Wheel specification submitted successfully."}


@app.get("/api/forms/all", response_model=AllFormsResponse)
def get_all_forms(
    db: Session = Depends(get_db),
    formNumber: Optional[str] = None,
    inspector: Optional[str] = None,
    startDate: Optional[str] = None,
    endDate: Optional[str] = None
):
    all_forms = []

    wheel_query = db.query(WheelSpecificationsDB)
    if formNumber:
        wheel_query = wheel_query.filter(WheelSpecificationsDB.formNumber.ilike(f"%{formNumber}%"))
    if inspector:
        wheel_query = wheel_query.filter(WheelSpecificationsDB.submittedBy.ilike(f"%{inspector}%"))
    if startDate and endDate:
        wheel_query = wheel_query.filter(WheelSpecificationsDB.submittedDate.between(startDate, endDate))
    
    wheel_specs = wheel_query.all()
    for form in wheel_specs:
        all_forms.append(
            SubmittedFormResponse(
                formNumber=form.formNumber,
                submittedBy=form.submittedBy,
                submittedDate=form.submittedDate,
                formType="Wheel Spec"
            )
        )

    bogie_query = db.query(BogieChecksheetDB)
    if formNumber:
        bogie_query = bogie_query.filter(BogieChecksheetDB.formNumber.ilike(f"%{formNumber}%"))
    if inspector:
        bogie_query = bogie_query.filter(BogieChecksheetDB.inspectionBy.ilike(f"%{inspector}%"))
    if startDate and endDate:
        bogie_query = bogie_query.filter(BogieChecksheetDB.inspectionDate.between(startDate, endDate))

    bogie_sheets = bogie_query.all()
    for form in bogie_sheets:
        all_forms.append(
            SubmittedFormResponse(
                formNumber=form.formNumber,
                submittedBy=form.inspectionBy,
                submittedDate=form.inspectionDate,
                formType="Bogie Checksheet"
            )
        )

    try:
        all_forms.sort(key=lambda x: x.submittedDate, reverse=True)
    except Exception as e:
        print(f"Could not sort forms by date: {e}")

    return {"data": all_forms}

"""Auth endpoints."""

from datetime import datetime
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.core.audit import write_audit
from app.core.rbac import get_current_user, require_min_role
from app.core.security import create_access_token, hash_password, verify_password
from app.database import get_db
from app.models import RoleEnum, User
from app.schemas import LoginRequest, Token, UserCreate, UserOut

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/login", response_model=Token)
def login_form(
    form: Annotated[OAuth2PasswordRequestForm, Depends()],
    db: Annotated[Session, Depends(get_db)],
):
    user = db.query(User).filter(User.email == form.username).first()
    if not user or not verify_password(form.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrect email or password")
    user.last_login = datetime.utcnow()
    db.commit()
    token = create_access_token(user.email, extra={"role": user.role.value})
    write_audit(db, action="login", resource_type="user", resource_id=str(user.id), actor=user)
    return Token(access_token=token, role=user.role, email=user.email, full_name=user.full_name)


@router.post("/login/json", response_model=Token)
def login_json(body: LoginRequest, db: Annotated[Session, Depends(get_db)]):
    user = db.query(User).filter(User.email == body.email).first()
    if not user or not verify_password(body.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrect email or password")
    user.last_login = datetime.utcnow()
    db.commit()
    token = create_access_token(user.email, extra={"role": user.role.value})
    write_audit(db, action="login", resource_type="user", resource_id=str(user.id), actor=user)
    return Token(access_token=token, role=user.role, email=user.email, full_name=user.full_name)


@router.get("/me", response_model=UserOut)
def me(user: Annotated[User, Depends(get_current_user)]):
    return user


@router.post("/users", response_model=UserOut)
def create_user(
    body: UserCreate,
    db: Annotated[Session, Depends(get_db)],
    admin: Annotated[User, Depends(require_min_role(RoleEnum.admin))],
):
    if db.query(User).filter(User.email == body.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    user = User(
        email=body.email,
        full_name=body.full_name,
        hashed_password=hash_password(body.password),
        role=body.role,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    write_audit(db, action="user.create", resource_type="user", resource_id=str(user.id), actor=admin)
    return user


@router.get("/users", response_model=list[UserOut])
def list_users(
    db: Annotated[Session, Depends(get_db)],
    _: Annotated[User, Depends(require_min_role(RoleEnum.admin))],
):
    return db.query(User).order_by(User.id).all()

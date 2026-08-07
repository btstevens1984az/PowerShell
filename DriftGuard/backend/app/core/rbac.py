"""RBAC dependencies and role checks."""

from __future__ import annotations

from typing import Annotated, Callable, Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from app.core.security import decode_token
from app.database import get_db
from app.models import RoleEnum, User

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login", auto_error=False)

ROLE_RANK = {
    RoleEnum.viewer: 1,
    RoleEnum.auditor: 2,
    RoleEnum.operator: 3,
    RoleEnum.admin: 4,
}


def get_current_user(
    token: Annotated[Optional[str], Depends(oauth2_scheme)],
    db: Annotated[Session, Depends(get_db)],
) -> User:
    if not token:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")
    try:
        payload = decode_token(token)
        email = payload.get("sub")
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token") from exc
    user = db.query(User).filter(User.email == email).first()
    if not user or not user.is_active:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User inactive or missing")
    return user


def get_optional_user(
    token: Annotated[Optional[str], Depends(oauth2_scheme)],
    db: Annotated[Session, Depends(get_db)],
) -> Optional[User]:
    if not token:
        return None
    try:
        return get_current_user(token, db)
    except HTTPException:
        return None


def require_roles(*roles: RoleEnum) -> Callable:
    def _dep(user: Annotated[User, Depends(get_current_user)]) -> User:
        if user.role not in roles and user.role != RoleEnum.admin:
            # Admin always allowed; otherwise require listed roles
            if RoleEnum.admin not in roles and user.role not in roles:
                min_ok = any(ROLE_RANK[user.role] >= ROLE_RANK[r] for r in roles)
                if not min_ok and user.role not in roles:
                    raise HTTPException(status_code=403, detail="Insufficient permissions")
        return user

    return _dep


def require_min_role(min_role: RoleEnum) -> Callable:
    def _dep(user: Annotated[User, Depends(get_current_user)]) -> User:
        if ROLE_RANK[user.role] < ROLE_RANK[min_role]:
            raise HTTPException(status_code=403, detail="Insufficient permissions")
        return user

    return _dep

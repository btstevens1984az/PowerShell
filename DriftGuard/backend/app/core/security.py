"""Security helpers: password hashing, JWT, Fernet secrets."""

from __future__ import annotations

from datetime import datetime, timedelta
from typing import Any, Optional

from cryptography.fernet import Fernet, InvalidToken
from jose import JWTError, jwt
from passlib.context import CryptContext

from app.config import get_settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
settings = get_settings()


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)


def create_access_token(subject: str, extra: Optional[dict[str, Any]] = None) -> str:
    expire = datetime.utcnow() + timedelta(minutes=settings.access_token_expire_minutes)
    payload: dict[str, Any] = {"sub": subject, "exp": expire, "type": "access"}
    if extra:
        payload.update(extra)
    return jwt.encode(payload, settings.secret_key, algorithm=settings.algorithm)


def decode_token(token: str) -> dict[str, Any]:
    try:
        return jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
    except JWTError as exc:
        raise ValueError("Invalid token") from exc


# Stable demo key (url-safe base64, 32 bytes) — override with SECRETS_FERNET_KEY in production
_DEMO_KEY = b"7Nd8ful9SRIHsYjBThipkMTdQLsvfOCBWwtcAq_T6KU="
try:
    _DEMO_FERNET = Fernet(_DEMO_KEY)
except Exception:  # noqa: BLE001
    _DEMO_FERNET = Fernet(Fernet.generate_key())


def _fernet() -> Fernet:
    key = settings.secrets_fernet_key
    if not key:
        return _DEMO_FERNET
    try:
        return Fernet(key.encode() if isinstance(key, str) else key)
    except Exception:  # noqa: BLE001
        return _DEMO_FERNET


def encrypt_secret(plaintext: str) -> str:
    return _fernet().encrypt(plaintext.encode()).decode()


def decrypt_secret(ciphertext: str) -> str:
    try:
        return _fernet().decrypt(ciphertext.encode()).decode()
    except InvalidToken as exc:
        raise ValueError("Unable to decrypt secret") from exc

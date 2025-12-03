"""Data models for Delivery and Schedule scrapers."""
from dataclasses import dataclass, field
from typing import Optional, List
from datetime import time


@dataclass
class ScheduleEntry:
    """Represents a single schedule entry (one day, one interval)."""
    day: int  # 1=Monday, 7=Sunday
    interval: int  # 1, 2, or 3
    time_start: Optional[str] = None  # HH:MM format (24-hour)
    time_stop: Optional[str] = None   # HH:MM format (24-hour)
    
    def is_valid(self) -> bool:
        """Check if this schedule entry has valid start and stop times."""
        return bool(self.time_start and self.time_stop and 
                   self.time_start.strip() and self.time_stop.strip())
    
    def to_dict(self) -> dict:
        return {
            'day': self.day,
            'interval': self.interval,
            'time_start': self.time_start,
            'time_stop': self.time_stop
        }


@dataclass
class RestaurantData:
    """Scraped data for a single restaurant."""
    v3_id: int
    legacy_id: int  # v1_id or v2_id depending on scraper
    name: str
    
    # Service settings
    delivery_time_minutes: Optional[int] = None
    takeout_time_minutes: Optional[int] = None
    has_delivery_enabled: Optional[bool] = None
    pickup_enabled: Optional[bool] = None
    closing_warning_minutes: Optional[int] = None  # V1 only
    
    # Schedules
    delivery_schedule: List[ScheduleEntry] = field(default_factory=list)
    takeout_schedule: List[ScheduleEntry] = field(default_factory=list)
    
    # Scraping metadata
    scrape_success: bool = False
    error_message: Optional[str] = None
    
    def to_dict(self) -> dict:
        return {
            'v3_id': self.v3_id,
            'legacy_id': self.legacy_id,
            'name': self.name,
            'delivery_time_minutes': self.delivery_time_minutes,
            'takeout_time_minutes': self.takeout_time_minutes,
            'has_delivery_enabled': self.has_delivery_enabled,
            'pickup_enabled': self.pickup_enabled,
            'closing_warning_minutes': self.closing_warning_minutes,
            'delivery_schedule': [s.to_dict() for s in self.delivery_schedule if s.is_valid()],
            'takeout_schedule': [s.to_dict() for s in self.takeout_schedule if s.is_valid()],
            'scrape_success': self.scrape_success,
            'error_message': self.error_message
        }


def parse_time_12h_to_24h(time_str: str) -> Optional[str]:
    """
    Convert 12-hour time format to 24-hour format.
    Examples: "11:30 AM" -> "11:30", "8:00 PM" -> "20:00"
    """
    if not time_str or not time_str.strip():
        return None
    
    time_str = time_str.strip().upper()
    
    try:
        # Handle formats like "11:30 AM", "8:00 PM"
        if 'AM' in time_str or 'PM' in time_str:
            is_pm = 'PM' in time_str
            time_str = time_str.replace('AM', '').replace('PM', '').strip()
            
            parts = time_str.split(':')
            if len(parts) != 2:
                return None
            
            hour = int(parts[0])
            minute = int(parts[1])
            
            if is_pm and hour != 12:
                hour += 12
            elif not is_pm and hour == 12:
                hour = 0
            
            return f"{hour:02d}:{minute:02d}"
        else:
            # Already in 24-hour format or just time
            parts = time_str.split(':')
            if len(parts) >= 2:
                hour = int(parts[0])
                minute = int(parts[1])
                return f"{hour:02d}:{minute:02d}"
            return None
    except (ValueError, IndexError):
        return None


def parse_time_v1(time_str: str) -> Optional[str]:
    """
    Parse V1 time format to 24-hour format.
    V1 uses formats like "11:30", "14:00", or just "0" for closed.
    """
    if not time_str or not time_str.strip():
        return None
    
    time_str = time_str.strip()
    
    # "0" means closed/not set
    if time_str == '0':
        return None
    
    try:
        parts = time_str.split(':')
        if len(parts) == 2:
            hour = int(parts[0])
            minute = int(parts[1])
            return f"{hour:02d}:{minute:02d}"
        elif len(parts) == 1:
            # Just hour
            hour = int(parts[0])
            return f"{hour:02d}:00"
        return None
    except (ValueError, IndexError):
        return None


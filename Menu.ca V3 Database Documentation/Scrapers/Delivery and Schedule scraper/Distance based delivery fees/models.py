"""Data models for Distance-Based Delivery Fees scraper."""
from dataclasses import dataclass, field
from typing import Optional, List, Dict, Any


@dataclass
class FeeTier:
    """Represents a single distance-based fee tier."""
    distance_km: int  # 5, 6, 7, 8, 9, or 10
    driver_earning: Optional[float] = None
    restaurant_pays: Optional[float] = None
    vendor_pays: Optional[float] = None
    total_delivery_fee: Optional[float] = None
    
    def is_valid(self) -> bool:
        """Check if tier has at least one fee value."""
        return any([
            self.driver_earning is not None,
            self.restaurant_pays is not None,
            self.vendor_pays is not None,
            self.total_delivery_fee is not None
        ])
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            'distance_km': self.distance_km,
            'driver_earning': self.driver_earning,
            'restaurant_pays': self.restaurant_pays,
            'vendor_pays': self.vendor_pays,
            'total_delivery_fee': self.total_delivery_fee
        }


@dataclass
class DistanceBasedFeeData:
    """
    Data scraped from V1 CRM delivery page for a single restaurant.
    """
    v3_id: int
    legacy_v1_id: int
    name: str
    
    # Whether restaurant uses distance-based delivery (sendToDelivery = 'y')
    uses_distance_based: bool = False
    
    # Delivery company emails (comma-separated in CRM)
    delivery_emails: List[str] = field(default_factory=list)
    
    # Commission and restaurant pays difference
    commission: Optional[float] = None
    restaurant_pays_difference: Optional[float] = None
    
    # Fee tiers for distances 5-10 km
    fee_tiers: List[FeeTier] = field(default_factory=list)
    
    # Scraping status
    scrape_success: bool = False
    error_message: Optional[str] = None
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            'v3_id': self.v3_id,
            'legacy_v1_id': self.legacy_v1_id,
            'name': self.name,
            'uses_distance_based': self.uses_distance_based,
            'delivery_emails': self.delivery_emails,
            'commission': self.commission,
            'restaurant_pays_difference': self.restaurant_pays_difference,
            'fee_tiers': [t.to_dict() for t in self.fee_tiers],
            'scrape_success': self.scrape_success,
            'error_message': self.error_message
        }


def parse_float(value: str) -> Optional[float]:
    """Parse a string to float, handling empty strings and invalid values."""
    if not value:
        return None
    value = value.strip().replace('$', '').replace(',', '')
    if not value:
        return None
    try:
        return float(value)
    except ValueError:
        return None

